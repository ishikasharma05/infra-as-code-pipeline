# Evidence

Raw output collected with the GitHub CLI and AWS CLI after the runs. Times are UTC.

## Pipeline run on main: staging deploy, approval, production deploy

```text
https://github.com/ishikasharma05/infra-as-code-pipeline/actions/runs/39057565677
Unit tests: success  2026-10-18T05:37:17Z -> 2026-10-18T05:37:27Z
Lint and validate: success  2026-10-18T05:37:17Z -> 2026-10-18T05:37:44Z
Build and push image: success  2026-10-18T05:37:47Z -> 2026-10-18T05:38:23Z
Deploy to staging: success  2026-10-18T05:38:26Z -> 2026-10-18T05:41:40Z
Deploy to production: success  2026-10-18T06:03:28Z -> 2026-10-18T06:06:43Z
```

## Deliberately broken release: the staging deploy failed and rolled back

```text
https://github.com/ishikasharma05/infra-as-code-pipeline/actions/runs/39057713506
Unit tests: success  2026-10-17T18:21:16Z -> 2026-10-17T18:21:28Z
Lint and validate: success  2026-10-17T18:21:16Z -> 2026-10-17T18:21:48Z
Build and push image: success  2026-10-17T18:21:51Z -> 2026-10-17T18:22:21Z
Deploy to staging: failure  2026-10-17T18:24:34Z -> 2026-10-17T18:30:12Z
Deploy to production: skipped  2026-10-17T18:30:13Z -> 2026-10-17T18:30:12Z
staging deploy job duration: 338 seconds


2026-10-17T18:24:38.3746878Z Deploying 662252246018.dkr.ecr.ap-south-1.amazonaws.com/iac-pipeline-staging-app:7cb18aa (version 7cb18aa) to staging
2026-10-17T18:24:40.3033341Z Current task definition: arn:aws:ecs:ap-south-1:662252246018:task-definition/iac-pipeline-staging-app:6
2026-10-17T18:24:42.9415958Z Registered new task definition: arn:aws:ecs:ap-south-1:662252246018:task-definition/iac-pipeline-staging-app:7
2026-10-17T18:30:07.6422719Z ##[error]Deployment of 7cb18aa to staging failed. Rolling back to arn:aws:ecs:ap-south-1:662252246018:task-definition/iac-pipeline-staging-app:6
```

