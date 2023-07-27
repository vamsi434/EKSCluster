terraform {
  required_version = ">= 1.0.0"
  backend "s3" {}
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }  
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }  
    http = {
      source  = "hashicorp/http"
      version = "3.3.0"
    }    
    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }        
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

provider "null" {}
provider "tls" {}
provider "http" {}
provider "archive" {}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  depends_on                = [module.eks]
  name                      = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on                = [module.eks]
  name                      = module.eks.cluster_name
}

provider "kubernetes" {
  host                      = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate    = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                     = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                    = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate  = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                   = data.aws_eks_cluster_auth.cluster.token
  }
}
