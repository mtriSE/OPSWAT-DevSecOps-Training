variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}
variable "key_name" { type = string }
variable "eks_cluster_version" {
  type    = string
  default = "1.25"
}
variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.micro"]
}
variable "microservices" {
  type = list(string)
}
variable "ecr_repo_urls" {
  type = map(string)
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
