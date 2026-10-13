variable "name" {
  description = "Name prefix applied to every resource in this module."
  type        = string
}

variable "environment" {
  description = "Environment name, passed to the app as APP_ENV."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "Subnets for the load balancer."
  type        = list(string)
}

variable "task_subnet_ids" {
  description = "Subnets where containers run."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Give containers a public IP. Needed only when there is no NAT gateway."
  type        = bool
}

variable "alb_security_group_id" {
  type = string
}

variable "tasks_security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "image_tag" {
  description = "Tag of the image in ECR that the first task definition uses."
  type        = string
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "min_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 6
}
