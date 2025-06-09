output "ec2_instance_id" {
  value = try(aws_instance.dev[0].id, null)
  description = "ID of the dev EC2 instance"
}

output "ec2_public_ip" {
    value = try(aws_instance.dev[0].public_ip, null)
    description = "Public IP of the dev EC2 instance"
}

output "ec2_sg_id" {
    value = try(aws_security_group.dev[0].id, null)
    description = "Security group ID for the dev EC2 instance (for DB access)"
}

output "eks_cluster_name" {
    value = try(module.eks[0].cluster_name, null)
    description = "Name of the EKS cluster"
}

output "eks_kubeconfig" {
    value = try(module.eks[0].kubeconfig, null)
    description = "Kubeconfig for the EKS cluster"
}

output "eks_node_sg_id" {
    value = try(module.eks[0].node_security_group_id, null)
    description = "EKS node group security group ID (for DB access)"
}

output "aws_ami_ubuntu_id" {
  value = data.aws_ami.ubuntu.id
  description = "ID of the Ubuntu AMI used for the dev EC2 instance"
}