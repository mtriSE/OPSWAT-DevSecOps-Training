variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project_name" {
  type    = string
  default = "opswat-devsecops"
}
variable "owner" {
  type    = string
  default = "tri-mai_opswat" # TODO 
}
variable "vpc_cidr" {
  type = string
}
variable "azs" {
  type = list(string)
}
variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_name" {
  type    = string
  default = ""
}
variable "eks_cluster_version" {
  type    = string
  default = "1.25"
}
variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.micro"]
}
variable "db_instance_class" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_username" {
  type      = string
  sensitive = true
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "rabbitmq_user" {
  type      = string
  sensitive = true
}
variable "rabbitmq_pass" {
  type      = string
  sensitive = true
}
variable "microservices" {
  type    = list(string)
  default = ["web", "proxy", "barista", "kitchen", "counter", "product"]
}
variable "messaging_instance_type" {
  type = string
}
