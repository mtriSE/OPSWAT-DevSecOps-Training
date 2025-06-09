output "vpc_id" { value = module.networking.vpc_id }
output "public_subnet_ids" { value = module.networking.public_subnet_ids }
output "private_subnet_ids" { value = module.networking.private_subnet_ids }
output "database_subnet_ids" { value = module.networking.database_subnet_ids }
output "db_endpoint" { value = module.database.endpoint }
output "ecr_repo_urls" { value = module.storage.ecr_repo_urls }
output "eks_cluster_name" { value = try(module.compute.eks_cluster_name, null) }
output "ec2_instance_id" { value = try(module.compute.ec2_instance_id, null) }
