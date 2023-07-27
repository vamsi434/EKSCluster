output "aws_nlb_name" {
  description = "Name of the aws Network Load Balancer"
  value       = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
}
