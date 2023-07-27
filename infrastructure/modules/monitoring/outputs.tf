output "grafana_credentials_name" {
  description = "AWS secretsmanager name where Grafan credentials are stored."
  value = aws_secretsmanager_secret.grafana_credentials.name
}

output "loki_s3_bucket" {
  description = "Name of the S3 bucker for loki."
  value       = aws_s3_bucket.loki_s3_bucket.id
}