locals {
  length                     = length(join("-", compact(["${var.prefix}","core-workers","${var.suffix}"])))
  cluster_name               = local.length > 24 ? substr("${join("-", compact(["${var.prefix}","eks","${var.suffix}"]))}",0,24)          : join("-", compact(["${var.prefix}","eks","${var.suffix}"]))
  core_workers_name          = local.length > 24 ? substr("${join("-", compact(["${var.prefix}","core-workers","${var.suffix}"]))}",0,24) : join("-", compact(["${var.prefix}","core-workers","${var.suffix}"])) 
  app_workers_name           = local.length > 24 ? substr("${join("-", compact(["${var.prefix}","app-workers","${var.suffix}"]))}",0,24)  : join("-", compact(["${var.prefix}","app-workers","${var.suffix}"]))
  cluster_oidc_issuer_url    = module.eks_cluster.cluster_oidc_issuer_url
  users                      = [
                                for key , user in var.eks_access_users :
                                  {  
                                  userarn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user.username}"
                                  username   = "${user.username}"
                                  groups     = ["${user.cluster_role}"]
                                  }
                               ]  
}
