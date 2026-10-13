variable "name" {
  description = "Name prefix applied to every resource in this module."
  type        = string
}

variable "retention_in_days" {
  description = "How long CloudWatch keeps container logs."
  type        = number
  default     = 7
}
