module "rds" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = "${var.db_name}-${var.environment}-rds"
  engine = "postgres"
  engine_version = "14.9"
  instance_class = var.instance_class
  allocated_storage = 20 # GB
  db_name = var.db_name
  username = var.username
  password = var.password
  vpc_security_group_ids = [aws_security_group.db.id] # Security group for the RDS instance
  db_subnet_group_name = aws_db_subnet_group.db.name # Subnet group for the RDS instance
  multi_az = var.environment == "prod"
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = var.environment == "prod"

  tags = {
    Project = var.project_name
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "db" {
  name = "${var.project_name}-${var.environment}-dbsubnet"
  subnet_ids = var.subnet_ids
  tags = {
    Name = "${var.project_name}-${var.environment}-dbsubnet"
  }
}

resource "aws_security_group" "db" {
  name = "${var.project_name}-${var.environment}-db-sg"
  description = "Allow DB access"
  vpc_id = var.vpc_id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = var.allowed_sg_ids # Allow access from specified security groups
    description = "Allow DB access from trusted security groups"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-db-sg"
  }
}