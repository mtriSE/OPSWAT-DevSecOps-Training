locals {
  environment = terraform.workspace
  is_dev      = local.environment == "dev"
  is_prod     = local.environment == "prod"
}

# Networking module - custom implementation for VPC, subnets, etc.
module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs
  environment  = local.environment
}

# Compute module - EC2 for dev, EKS for prod
module "compute" {
  source = "./modules/compute"
  project_name    = var.project_name
  environment     = local.environment
  vpc_id          = module.networking.vpc_id
  public_subnets  = module.networking.public_subnet_ids
  private_subnets = module.networking.private_subnet_ids

  # EC2 specific variables (used only in dev)
  ec2_instance_type = var.ec2_instance_type
  key_name          = var.key_name # used for secure access to the instance

  # EKS specific variables (used only in prod)
  eks_cluster_version     = var.eks_cluster_version
  eks_node_instance_types = var.eks_node_instance_types

  # Common variables
  microservices = var.microservices
  ecr_repo_urls  = module.storage.ecr_repo_urls # AWS ECR repository URLs for microservices
  aws_region = var.aws_region
}

# Database module
module "database" {
  source = "./modules/database"
  project_name    = var.project_name
  environment     = local.environment
  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.database_subnet_ids
  instance_class  = var.db_instance_class
  db_name         = var.db_name
  username        = var.db_username
  password        = var.db_password
  allowed_sg_ids = [module.compute.ec2_sg_id, module.compute.eks_node_sg_id]
}

# Storage module (ECR, S3)
module "storage" {
  source = "./modules/storage"
  project_name  = var.project_name
  environment   = local.environment
  microservices = var.microservices
}


# Security module
module "security" {
  source = "./modules/security"
  project_name  = var.project_name
  environment   = local.environment
  db_endpoint   = module.database.endpoint
  db_username   = var.db_username
  db_password   = var.db_password
  rabbitmq_user = var.rabbitmq_user
  rabbitmq_pass = var.rabbitmq_pass
}

module "monitoring" {
  source = "./modules/monitoring"
  project_name  = var.project_name
  environment   = local.environment
  vpc_id        = module.networking.vpc_id
  create_grafana = local.is_prod
}

# Messaging module
module "messaging" {
  source = "./modules/messaging"
  project_name  = var.project_name
  environment   = local.environment
  vpc_id        = module.networking.vpc_id
  subnet_ids    = module.networking.public_subnet_ids
  instance_type = var.messaging_instance_type
  key_name      = var.key_name
  allowed_sg_ids = [
    module.compute.ec2_sg_id,   # dev
    module.compute.eks_node_sg_id # prod
  ]
}
