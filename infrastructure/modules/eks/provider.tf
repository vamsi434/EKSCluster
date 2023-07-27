data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  depends_on              = [local.cluster_oidc_issuer_url ]
  name                    = module.eks_cluster.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on              = [local.cluster_oidc_issuer_url ]
  name                    = module.eks_cluster.cluster_name
}

provider "kubernetes" {
  host                    = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                   = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
 }
