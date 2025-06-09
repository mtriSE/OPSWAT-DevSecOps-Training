locals {
  is_dev  = var.environment == "dev"
  is_prod = var.environment == "prod"
}

# ========================
# DEV ENVIRONMENT: EC2
# ========================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "dev" {
  count  = local.is_dev ? 1 : 0
  name   = "${var.project_name}-dev-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RabbitMQ Management"
  }

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RabbitMQ AMQP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dev" {
  count                       = local.is_dev ? 1 : 0
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.public_subnets[0]
  key_name                    = var.key_name != "" ? var.key_name : null
  vpc_security_group_ids      = [aws_security_group.dev[0].id]
  associate_public_ip_address = true

  tags = {
    Name        = "${var.project_name}-dev-ec2"
    Environment = var.environment
  }

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    microservices = var.microservices
    ecr_repo_urls = var.ecr_repo_urls
    aws_region    = var.aws_region
  })
}

# ========================
# PROD ENVIRONMENT: EKS
# ========================
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  count           = local.is_prod ? 1 : 0

  cluster_name    = "${var.project_name}-prod-eks"
  cluster_version = var.eks_cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = var.eks_node_instance_types
      subnet_ids       = var.private_subnets
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = []
  aws_auth_users = []
  aws_auth_accounts = []

  tags = {
    Environment = "prod"
    Project     = var.project_name
  }
}

resource "aws_security_group" "eks_additional" {
  count  = local.is_prod ? 1 : 0
  name   = "${var.project_name}-prod-eks-additional-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"] # Internal from VPC
    description = "Cluster internal"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}