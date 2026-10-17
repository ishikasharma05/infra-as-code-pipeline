#!/usr/bin/env bash
# Deploys a container image to an ECS service and rolls back automatically if it is unhealthy.
# Usage: bash scripts/deploy.sh <environment> <image-uri> <version>
set -euo pipefail

ENV_NAME="${1:?environment name required (dev, staging, prod)}"
IMAGE="${2:?image URI required}"
VERSION="${3:?version required}"

REGION="${AWS_REGION:-ap-south-1}"
CLUSTER="iac-pipeline-${ENV_NAME}-cluster"
SERVICE="iac-pipeline-${ENV_NAME}-service"
ALB_NAME="iac-pipeline-${ENV_NAME}-alb"
WAIT_SECONDS="${WAIT_SECONDS:-300}"
WORKDIR="$(mktemp -d)"

echo "Deploying ${IMAGE} (version ${VERSION}) to ${ENV_NAME}"

# 1. Remember what is running now, so we can go back to it.
PREVIOUS_TD=$(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" \
  --region "$REGION" --query 'services[0].taskDefinition' --output text)
echo "Current task definition: ${PREVIOUS_TD}"

# 2. Build a new task definition from the current one with the new image.
aws ecs describe-task-definition --task-definition "$PREVIOUS_TD" --region "$REGION" \
  --query taskDefinition > "${WORKDIR}/current.json"

jq --arg IMAGE "$IMAGE" --arg VERSION "$VERSION" '
  .containerDefinitions[0].image = $IMAGE
  | .containerDefinitions[0].environment |= map(if .name == "APP_VERSION" then .value = $VERSION else . end)
  | {family, taskRoleArn, executionRoleArn, networkMode, containerDefinitions, volumes,
     placementConstraints, requiresCompatibilities, cpu, memory, runtimePlatform}
  | with_entries(select(.value != null))
' "${WORKDIR}/current.json" > "${WORKDIR}/new.json"

NEW_TD=$(aws ecs register-task-definition --cli-input-json "file://${WORKDIR}/new.json" \
  --region "$REGION" --query 'taskDefinition.taskDefinitionArn' --output text)
echo "Registered new task definition: ${NEW_TD}"

ALB_DNS=$(aws elbv2 describe-load-balancers --names "$ALB_NAME" --region "$REGION" \
  --query 'LoadBalancers[0].DNSName' --output text)

rollback() {
  echo "::error::Deployment of ${VERSION} to ${ENV_NAME} failed. Rolling back to ${PREVIOUS_TD}"
  aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" \
    --task-definition "$PREVIOUS_TD" --region "$REGION" > /dev/null
  timeout "$WAIT_SECONDS" aws ecs wait services-stable --cluster "$CLUSTER" \
    --services "$SERVICE" --region "$REGION" || echo "Rollback did not stabilise in time, check the service"
  exit 1
}

verify() {
  local ok=0 body
  for _ in $(seq 1 30); do
    if curl -fsS --max-time 5 "http://${ALB_DNS}/health" > /dev/null \
       && body=$(curl -fsS --max-time 5 "http://${ALB_DNS}/") \
       && [[ "$body" == *"version ${VERSION}"* ]]; then
      ok=$((ok + 1))
    else
      ok=0
    fi
    if [ "$ok" -ge 5 ]; then return 0; fi
    sleep 4
  done
  return 1
}

# 3. Point the service at the new task definition.
START=$(date +%s)
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" \
  --task-definition "$NEW_TD" --region "$REGION" > /dev/null

# 4. Wait for ECS to report a stable service, then check from the outside.
if ! timeout "$WAIT_SECONDS" aws ecs wait services-stable --cluster "$CLUSTER" \
     --services "$SERVICE" --region "$REGION"; then
  rollback
fi

if ! verify; then
  rollback
fi

echo "Deployment of ${VERSION} to ${ENV_NAME} succeeded in $(( $(date +%s) - START ))s"
