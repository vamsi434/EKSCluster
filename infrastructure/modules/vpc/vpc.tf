data "aws_availability_zones" "available" {}

/******************
       VPC 
*******************/
module "vpc" {
  source                        = "terraform-aws-modules/vpc/aws"
  version                       = "4.0.1"
  name                          = local.vpc_name
  cidr                          = var.vpc_ip_cidr
  azs                           = data.aws_availability_zones.available.names
  private_subnets               = cidrsubnets(var.vpc_ip_cidr, 4, 4, 4)   # https://developer.hashicorp.com/terraform/language/functions/cidrsubnet
  public_subnets                = cidrsubnets(cidrsubnet(var.vpc_ip_cidr, 2, 2), 2, 2, 2)
  enable_nat_gateway            = true
  single_nat_gateway            = true
  enable_dns_hostnames          = true
  manage_default_security_group = false
  tags = {
    workload                    = "vpc"
  }  
  public_subnet_tags   = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    "type"                                        = "public"
  }
  private_subnet_tags  = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "type"                                        = "private"
  }
}


data "aws_route_tables" "rts" {
  vpc_id               = module.vpc.vpc_id
}

/******************
  Endpoint for S3
*******************/
module "endpoints" {
  source               = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version              = "4.0.1"
  vpc_id               = module.vpc.vpc_id
  endpoints = {
    s3 = {
      service          = "s3"
      service_type     = "Gateway"
      route_table_ids  = tolist(data.aws_route_tables.rts.ids)
      tags             = { Name = "s3-vpc-endpoint" }      
    },
    dynamodb = {
      service          = "dynamodb"
      service_type     = "Gateway"
      route_table_ids  = tolist(data.aws_route_tables.rts.ids)
      tags             = { Name = "dynamodb-vpc-endpoint" }      
    },
  }
  tags = {
    workload           = "vpc"
  }  
}