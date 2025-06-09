output "endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_name" {
    value = module.rds.db_instance_name
}

output "db_sg_id" {
    value = aws_security_group.db.id
}