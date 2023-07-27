output "host_ip" {
  description = "The public IP address assigned to bastion host."
  value       = aws_eip.bastion_host.public_ip
}

output "arn" {
  description = "The ARN of bastion host."
  value       = module.bastion_host.arn
}
