/***********************************************************************************************
                                     AWS EBS-CSI Driver
https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/helm-chart-aws-ebs-csi-driver-2.18.0  
************************************************************************************************/

# # Installation of AWS EBS-CSI Driver
resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.18.0"
  atomic     = true
  values = [
    <<EOT
controller:
  extraVolumeTags:
${local.ebs_volume_tags}
  resources:
    requests:
      cpu: 5m
      memory: 100Mi   
node:
  resources:
    requests:
      cpu: 1m
      memory: 30Mi 
EOT
  ] 
}
