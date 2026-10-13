variable "name" {
  description = "Name prefix applied to every resource in this module."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the security groups belong to."
  type        = string
}

variable "container_port" {
  description = "Port the application container listens on."
  type        = number
  default     = 3000
}
