variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR range of the VPC for this environment."
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT gateway for this environment."
  type        = bool
}

variable "container_port" {
  description = "Port the application container listens on."
  type        = number
  default     = 3000
}
