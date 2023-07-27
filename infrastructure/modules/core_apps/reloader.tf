/****************************************************************************************
                      Reloader to restart PODs on any config change
                    https://github.com/stakater/Reloader/tree/v1.0.24 
*****************************************************************************************/

# # Installation of Reloader
resource "helm_release" "reloader" {
  name       = "reloader"
  namespace  = "kube-system"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version    = "v1.0.24"
  atomic     = true  
  values     = [
    <<EOT
fullnameOverride: "reloader" 
reloader:
  deployment:
    resources:
      requests:
        cpu: "10m"
        memory: "128Mi"
EOT
  ]
}