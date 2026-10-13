variable "name" {
  description = "Name prefix applied to every resource in this module."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range of the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway so private subnets can reach the internet. Costs about $33/month."
  type        = bool
  default     = true
}
