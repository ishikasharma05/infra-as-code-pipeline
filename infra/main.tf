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
