locals {
  is_dev  = var.environment == "dev"
  is_prod = var.environment == "prod"
}

resource "aws_security_group" "rabbitmq" {
  name        = "${var.project_name}-${var.environment}-rabbitmq-sg"
  description = "Allow RabbitMQ traffic"
  vpc_id      = var.vpc_id

  #   5672 - AMQP, 15672 - Management UI
  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = var.allowed_sg_ids
    description     = "Allow AMQP traffic from compute security groups"
  }
  ingress {
    from_port       = 15672
    to_port         = 15672
    protocol        = "tcp"
    security_groups = var.allowed_sg_ids
    description     = "Allow RabbitMQ Management UI traffic from compute security groups"
  }

  # Optionally, for dev, allow management UI from my IP
  dynamic "ingress" {
    for_each = local.is_dev ? [1] : []
    content {
      from_port   = 15672
      to_port     = 15672
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # TODO: tighten this to your IP
      description = "Allow RabbitMQ Management UI traffic from anywhere (dev only)"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rabbitmq-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# In dev, deploy a simple EC2 with Docker running RabbitMQ
resource "aws_instance" "rabbitmq" {
  count                  = local.is_dev ? 1 : 0
  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, 0) #? Use the first subnet (dev)
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.rabbitmq.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    docker run -d --name rabbitmq \
      --restart=always \
      -p 5672:5672 \ 
      -p 15672:15672 \
      rabbitmq:3-management
    EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-rabbitmq"
    Environment = var.environment
    Project     = var.project_name
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


