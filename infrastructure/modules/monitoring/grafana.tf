/**********************************
  Aws Secrects For Grafana Login
***********************************/
resource "random_password" "grafana" {
  length            = 20
  special           = false
}

resource "aws_secretsmanager_secret" "grafana_credentials" {
  name              = "${local.grafana_secret}"
  description       = "Credentials of Grafana."
  tags   = {    
    workload        = "monitoring"
  }   
}

resource "aws_secretsmanager_secret_version" "grafana_credentials" {  
  secret_id         = aws_secretsmanager_secret.grafana_credentials.id
  secret_string     = <<EOF
  {
    "username": "admin",
    "password": "${random_password.grafana.result}",
  }
  EOF  
}

/****************************************************************
                      Installing Grafana
  https://github.com/grafana/helm-charts/tree/main/charts/grafana    
*****************************************************************/
resource "helm_release" "grafana" {
  name              = "grafana"
  namespace         = "monitoring"
  chart             = "grafana"
  repository        = "https://grafana.github.io/helm-charts"
  version           = "6.56.4"
  atomic            = true
  timeout           = 1200
  values            =   [<<EOT
serviceMonitor:
  enabled: true
  namespace: monitoring

ingress:
  enabled: ${var.domain_name == "" ? "false" : "true"}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/whitelist-source-range: ${local.vpn_ips}
  labels: {}
  path: "/"
  hosts:
    - grafana.${var.domain_name}

resources:
 requests:
   cpu: 25m
   memory: 100Mi

persistence:
  enabled: true

plugins:
  - digrich-bubblechart-panel
  - grafana-clock-panel
  - grafana-piechart-panel
  - marcusolsson-gantt-panel
  - grafana-worldmap-panel

datasources:
 datasources.yaml:
   apiVersion: 1
   datasources:
   - name: Prometheus
     type: prometheus
     url: http://prometheus-prometheus:9090
     access: proxy
     isDefault: true
   - name: Loki
     type: loki
     url: http://loki-gateway:80
     access: proxy
     isDefault: false

dashboardProviders:
 dashboardproviders.yaml:
   apiVersion: 1
   providers:
   - name: 'default'
     orgId: 1
     folder: 'default'
     type: file
     disableDeletion: false
     editable: true
     options:
       path: /var/lib/grafana/dashboards/default   

dashboards:
  default:
    prometheus-stats:
      gnetId: 2
      revision: 2
      datasource: Prometheus  
    nginx-ingress:
      gnetId: 9614
      revision: 1
      datasource: Prometheus           
    kubernetes-cluster:
      gnetId: 7249
      datasource: Prometheus
    kubernetes-cluster-monitoring-prometheus:
      gnetId: 1621
      datasource: Prometheus
    django-mixin:
      gnetId: 17613
      datasource: Prometheus
    django-monitors:
      gnetId: 17616
      datasource: Prometheus          

sidecar:
  dashboards:
    enabled: true
    label: grafana_dashboard    
                              EOT
                        ]
set_sensitive {
  name  = "adminUser"
  value = "admin"
}
set_sensitive {
  name  = "adminPassword"
  value = "${random_password.grafana.result}"
}                        
}

# Adding DNS record of the NLB
data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

data "aws_lb" "nginx_ingress" {
  tags = {
    "elbv2.k8s.aws/cluster"      = "${var.cluster_name}",
    "service.k8s.aws/resource"   = "LoadBalancer",
    "service.k8s.aws/stack"      = "ingress-nginx/ingress-nginx-controller"
  }  
}

module "route53_record" { 
  count     = "${var.domain_name == "" ? 0 : 1}"  
  source    = "terraform-aws-modules/route53/aws//modules/records"
  version   = "2.10.2"
  zone_name = "${var.domain_name}"
  records   = [
    {
      allow_overwrite = true      
      name    = "grafana"
      type    = "A"
      alias   = {
        name                   = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
        zone_id                = data.aws_lb.nginx_ingress.zone_id
        evaluate_target_health = true
      }
    },
  ]
}

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-additional-dashboards"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "true"
    }
  }
  data = {
    for file_path in fileset("", "${path.module}/grafana_dashboards/*.json") : basename(file_path) => file(file_path)
  }
}