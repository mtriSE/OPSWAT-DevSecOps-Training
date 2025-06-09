output "rabbitmq_sg_id" {
    value = aws_security_group.rabbitmq.id
    description = "Security group ID for RabbitMQ"
}

output "rabbitmq_instance_id" {
    value = try(aws_instance.rabbitmq[0].id, null)
    description = "ID of the RabbitMQ EC2 instance (dev only)"
}

output "rabbitmq_public_ip" {
    value = try(aws_instance.rabbitmq[0].public_ip, null)
    description = "Public IP of the RabbitMQ EC2 instance (dev only)"
}