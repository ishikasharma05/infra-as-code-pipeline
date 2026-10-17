data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # Terraform environment name => GitHub Environment name
  environments = {
    staging = "staging"
    prod    = "production"
  }
}

# ---------- Trust GitHub's identity tokens ----------
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # As far as I know AWS now validates GitHub's certificate chain itself and
  # ignores these values, but the field is still accepted and harmless.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

# ---------- Who may assume each role ----------
data "aws_iam_policy_document" "trust" {
  for_each = local.environments

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only jobs from this repo, running in this specific GitHub Environment
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:environment:${each.value}"]
    }
  }
}

resource "aws_iam_role" "deploy" {
  for_each = local.environments

  name                 = "iac-pipeline-github-${each.key}"
  assume_role_policy   = data.aws_iam_policy_document.trust[each.key].json
  max_session_duration = 3600
}

# ---------- What each role may do ----------
data "aws_iam_policy_document" "permissions" {
  for_each = local.environments

  statement {
    sid     = "DeployToOwnService"
    actions = ["ecs:DescribeServices", "ecs:UpdateService"]
    resources = [
      "arn:aws:ecs:${var.aws_region}:${local.account_id}:service/iac-pipeline-${each.key}-cluster/iac-pipeline-${each.key}-service"
    ]
  }

  # These ECS actions do not support resource-level permissions
  statement {
    sid       = "TaskDefinitions"
    actions   = ["ecs:DescribeTaskDefinition", "ecs:RegisterTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid       = "FindLoadBalancer"
    actions   = ["elbv2:DescribeLoadBalancers"]
    resources = ["*"]
  }

  statement {
    sid     = "PassTaskRoles"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${local.account_id}:role/iac-pipeline-${each.key}-ecs-execution-role",
      "arn:aws:iam::${local.account_id}:role/iac-pipeline-${each.key}-ecs-task-role",
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  # Only the staging role pushes images
  dynamic "statement" {
    for_each = each.key == "staging" ? [1] : []

    content {
      sid       = "EcrLogin"
      actions   = ["ecr:GetAuthorizationToken"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = each.key == "staging" ? [1] : []

    content {
      sid = "EcrPush"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:DescribeImages",
      ]
      resources = ["arn:aws:ecr:${var.aws_region}:${local.account_id}:repository/iac-pipeline-staging-app"]
    }
  }
}

resource "aws_iam_role_policy" "deploy" {
  for_each = local.environments

  name   = "deploy-permissions"
  role   = aws_iam_role.deploy[each.key].id
  policy = data.aws_iam_policy_document.permissions[each.key].json
}
