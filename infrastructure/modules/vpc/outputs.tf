output "vpc_name" {
  description = "The name of the VPC."  
  value       = module.vpc.name
}

output "vpc_id" {
  description = "ID of the created VPC."  
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."  
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of private subnets for the VPC."  
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnets for the VPC."  
  value       = module.vpc.public_subnets
}

output "endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created."  
  value       = module.endpoints.endpoints
}