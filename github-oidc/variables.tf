variable "aws_region" {
  description = "AWS region of the deployment targets."
  type        = string
  default     = "ap-south-1"
}

variable "github_repo" {
  description = "GitHub repository allowed to deploy, in owner/name form."
  type        = string
  default     = "ishikasharma05/infra-as-code-pipeline"
}
