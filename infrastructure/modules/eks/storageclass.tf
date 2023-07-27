/***********************************************************************************************
                      Creating GP3 encrypted Srorage Class for EKS 
************************************************************************************************/

# # Creating GP3 Storage Class
resource "kubernetes_storage_class" "gp3_encrypted" {
  depends_on              = [module.eks_cluster ] 
  storage_provisioner     = "ebs.csi.aws.com"
  reclaim_policy          = "Delete"
  volume_binding_mode     = "WaitForFirstConsumer"
  allow_volume_expansion  = true   
  metadata {
    name        = "gp3-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  parameters  = {
    type      = "gp3"
    encrypted = "true"
    "csi.storage.k8s.io/fstype" = "ext4"
  }
}

# # Setting the GP2 storage class as not the default class
resource "null_resource" "gp2_annotation_patcher" {
  depends_on  = [null_resource.update_kubeconfig ]   
  provisioner "local-exec" {
    command   = <<EOH
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
EOH
  }
}
