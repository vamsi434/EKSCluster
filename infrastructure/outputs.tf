output "vpc_name" {
  description = "The name of the VPC."  
  value       = module.vpc.vpc_name
}

output "vpc_id" {
  description = "ID of the created VPC."  
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."  
  value       = module.vpc.vpc_cidr_block
}

output "vpc_private_subnets" {
  description = "List of private subnets for the VPC."  
  value       = join(", ",module.vpc.private_subnets)
}

output "vpc_public_subnets" {
  description = "List of public subnets for the VPC."  
  value       = join(", ",module.vpc.public_subnets)
}

output "security_group_id_bastion_host" {
  description = "Details of the bastion host security group."
  value       = module.security_group.bastion_host_sg_id 
}

output "security_group_id_self_reference" {
  description = "Details of the self reference security group."
  value       = module.security_group.self_reference_sg_id
}

output "ssh_key_name" {
  description = "Name of the created Key Pair."
  value       = module.ssh_key_pair.ssh_key_name  
}

output "bastion_host_ip" {
  description = "IP for bastion host used for connecting to database."
  value       = var.database_public_access == true ? null : module.bastion_host[0].host_ip 
}

output "bastion_host_arn" {
  description = "IP for bastion host used for connecting to database."
  value       = var.database_public_access == true ? null : module.bastion_host[0].arn 
}

output "database_cluster_parameter_group_name" {
  description = "Cluster parameter group name for the database."  
  value       = module.database.database_cluster_parameter_group_name
}

output "database_credentials_secretname" {
  description = "AWS secrect name where database credentials are stored."
  value       = module.database.database_credentials_secretname
}

output "database_name" {
  description = "Name of the default database."
  value       = module.database.database_name
}

output "eks_cluster_name" {
  description = "Amazon Elastic Kubernetes cluster name."
  value       = module.eks.cluster_name
}

output "grafana_host_url" {
  description = "Hosted URL for Grafana."
  value       = var.domain_name == "" ? null : "https://grafana.${var.domain_name}"
}

output "grafana_secrect_name" {
  description = "AWS secrect name where grafana credentials are stored."
  value       = module.monitoring.grafana_credentials_name
}

output "aws_nlb_hostname" {
  description = "AWS network-load-balancer name."
  value       = module.core_apps.aws_nlb_name
}

output "loki_s3_bucket" {
  description = "S3 bucket where loki logs are stored."
  value       = module.monitoring.loki_s3_bucket
}


output "aws_region" {
 description   = "AWS Region in which all the resources are getting created."  
 value         =  data.aws_region.current.description
}