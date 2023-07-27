/**************************************************************************************
                                    Metrics Server
https://github.com/kubernetes-sigs/metrics-server/tree/metrics-server-helm-chart-3.10.0   
****************************************************************************************/

# # Installation of Metrics Server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.10.0"
  atomic     = true
  values     = [
    <<EOT
fullnameOverride: "metrics-server"
resources:
 requests:
   cpu: 10m
   memory: 64Mi
  EOT
  ]
}