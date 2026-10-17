variable "aws_region" {
  description = "AWS region of the deployment targets."
  type        = string
  default     = "ap-south-1"
}

variable "github_subject_prefix" {
  description = "Subject prefix GitHub puts in OIDC tokens for this repository (immutable form: owner@ownerId/repo@repoId)."
  type        = string
  default     = "repo:ishikasharma05@217627965/infra-as-code-pipeline@1414421859"
}
