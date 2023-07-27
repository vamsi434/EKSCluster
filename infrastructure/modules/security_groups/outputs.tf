output "bastion_host_security_group_name" {
  description = "The name of the security group for Bastion host."
  value       = module.bastion_host_sg.security_group_name
}

output "bastion_host_sg_id" {
  description = "Security group ID for Bastion host."
  value       = module.bastion_host_sg.security_group_id
}

output "self_reference_security_group_name" {
  description = "The name of the security group for Self Referene."
  value       = module.self_reference_sg.security_group_name
}

output "self_reference_sg_id" {
  description = "Self Referene Security Group"
  value       = module.self_reference_sg.security_group_id
}
