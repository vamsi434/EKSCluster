output "database_parameter_group_name" {
  description = "Database parameter group name."  
  value       = aws_db_parameter_group.db_parameter_group.name
}

output "database_cluster_parameter_group_name" {
  description = "Cluster parameter group name for the database."  
  value       = aws_rds_cluster_parameter_group.parameter_group.name
}

output "database_credentials_secretname" {
  description = "Database credentials name."  
  value       = aws_secretsmanager_secret.rds_credentials.name
}

output "database_name" {
  description = "Name of the database."  
  value       = module.aurora_postgresql_v2.cluster_database_name
}

output "database_subnet_group_name" {
  description = "The subnet group name of the database."  
  value       = module.aurora_postgresql_v2.db_subnet_group_name
}