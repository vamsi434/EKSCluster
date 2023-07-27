/******************
        VPC
*******************/
module "vpc" {
  source                      = "./modules/vpc"
  prefix                      = var.prefix
  suffix                      = var.suffix
  vpc_ip_cidr                 = var.vpc_ip_cidr  
}

/******************
  Security Groups
*******************/
module "security_group" {
  depends_on                  = [module.vpc]
  source                      = "./modules/security_groups"
  prefix                      = var.prefix
  suffix                      = var.suffix 
  bastion_host_public_access  = var.bastion_host_public_access 
  vpn_ips                     = var.vpn_ips        
  vpc_id                      = module.vpc.vpc_id
}

/*******************
  Key-Pair for SSH
********************/
module "ssh_key_pair" {
  source                      = "./modules/ssh_key_pair"  
  prefix                      = var.prefix
  suffix                      = var.suffix 
  ssh_key_name                = var.ssh_key_name
}

/******************
  Bastion Host
*******************/
module "bastion_host" {
  count                       = "${var.database_public_access == true ? 0 : 1}"
  depends_on                  = [module.vpc]  
  source                      = "./modules/bastion_host"
  prefix                      = var.prefix
  suffix                      = var.suffix  
  bastion_host_ami            = var.bastion_host_ami
  instance_type               = var.bastion_host_instance_type
  ssh_key_name                = module.ssh_key_pair.ssh_key_name 
  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  security_group_ids          = [ module.security_group.self_reference_sg_id, 
                                  module.security_group.bastion_host_sg_id ]
}

/********************************
  RDS Aurora Serverless Database
*********************************/
module "database"{
  depends_on                  = [module.vpc]  
  source                      = "./modules/database"
  prefix                      = var.prefix
  suffix                      = var.suffix    
  db_master_username          = var.db_master_username
  max_acu_capacity            = var.max_acu_capacity    
  min_acu_capacity            = var.min_acu_capacity
  db_monitoring_interval      = var.db_monitoring_interval
  db_skip_final_snapshot      = var.db_skip_final_snapshot 
  database_public_access      = var.database_public_access
  enable_performance_insights = var.enable_performance_insights
  db_log_retention_period     = var.performance_insights_retention_period    
  vpc_id                      = module.vpc.vpc_id  
  private_subnets_ids         = module.vpc.private_subnets
  public_subnets_ids          = module.vpc.public_subnets  
  security_group_ids          = [ module.security_group.self_reference_sg_id ] 
}

/******************
  EKS Cluster
*******************/
module "eks" {
  source                      = "./modules/eks"
  prefix                      = var.prefix
  suffix                      = var.suffix  
  aws_region                  = var.aws_region
  aws_profile                 = var.aws_profile    
  eks_access_users            = var.eks_access_users 
  create_cloudwatch_log_group = var.create_cloudwatch_log_group
  eks_additional_policies     = var.eks_additional_policies 
  core_node_group_configs     = var.core_node_group_configs
  app_node_group_configs      = var.app_node_group_configs    
  vpc_id                      = module.vpc.vpc_id
  private_subnets_ids         = module.vpc.private_subnets
  public_subnets_ids          = module.vpc.public_subnets
  ssh_key_name                = module.ssh_key_pair.ssh_key_name    
  security_group_ids          = [ module.security_group.self_reference_sg_id ] 
}

/******************
  Core Apps for EKS
*******************/
module "core_apps" {
  depends_on                  = [module.eks]
  source                      = "./modules/core_apps"
  prefix                      = var.prefix 
  suffix                      = var.suffix    
  tags                        = var.tags    
  aws_region                  = var.aws_region   
  domain_name                 = var.domain_name  
  ssl_certificates            = var.ssl_certificates 
  nginx_annotations           = var.nginx_annotations
  enable_internet_facing_lb   = var.enable_internet_facing_lb
  vpc_ip_cidr                 = module.vpc.vpc_cidr_block     
  cluster_name                = module.eks.cluster_name
  oidc_provider_arn           = module.eks.oidc_provider_arn  
  cluster_oidc_issuer_url     = module.eks.cluster_oidc_issuer_url  
}

/******************
  Monitoring tools
*******************/
module "monitoring" {
  depends_on                  = [module.core_apps]
  source                      = "./modules/monitoring"
  prefix                      = var.prefix
  suffix                      = var.suffix  
  aws_region                  = var.aws_region
  domain_name                 = var.domain_name  
  vpn_ips                     = var.vpn_ips   
  vpn_restriction             = var.vpn_restriction
  cluster_name                = module.eks.cluster_name  
  vpc_ip_cidr                 = module.vpc.vpc_cidr_block  
}