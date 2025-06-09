variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = null
}

variable "allowed_sg_ids" {
  type        = list(string)
  description = "List of security group IDs allowed to access RabbitMQ (compute etc)"
  default     = []
}

variable "ami_id" {
  description = "AMI for the RabbitMQ instance"
  type        = string
  default     = null
}
