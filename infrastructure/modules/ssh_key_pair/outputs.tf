output "ssh_key_name" {
  description = "Name of the SSH Key Pair."
  value       = aws_key_pair.admin_ssh_key.key_name
}
