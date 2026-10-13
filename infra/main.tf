locals {
  name = "iac-pipeline-${terraform.workspace}"
}

module "networking" {
  source = "./modules/networking"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
}

module "security" {
  source = "./modules/security"

  name           = local.name
  vpc_id         = module.networking.vpc_id
  container_port = var.container_port
}

module "monitoring" {
  source = "./modules/monitoring"

  name = local.name
}

module "compute" {
  source = "./modules/compute"

  name        = local.name
  environment = terraform.workspace

  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  task_subnet_ids   = var.enable_nat_gateway ? module.networking.private_subnet_ids : module.networking.public_subnet_ids
  assign_public_ip  = !var.enable_nat_gateway

  alb_security_group_id   = module.security.alb_security_group_id
  tasks_security_group_id = module.security.tasks_security_group_id
  execution_role_arn      = module.security.execution_role_arn
  task_role_arn           = module.security.task_role_arn

  log_group_name = module.monitoring.log_group_name
  container_port = var.container_port
  image_tag      = var.image_tag
}
