/*************************************************************************************************************
                                                   AWS EKS Cluster
        https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.15.3                                     
https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf
**************************************************************************************************************/

# # Creation of AWS EKS
module "eks_cluster" {
  source                                    = "terraform-aws-modules/eks/aws"
  version                                   = "19.15.3" 
  cluster_version                           = "1.27"
  cluster_name                              = local.cluster_name
  vpc_id                                    = var.vpc_id
  control_plane_subnet_ids                  = concat(var.private_subnets_ids, var.public_subnets_ids) 
  subnet_ids                                = var.private_subnets_ids
  create_cloudwatch_log_group               = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days    = "${var.create_cloudwatch_log_group == true ? "7" : "0"}"
  cluster_enabled_log_types                 = "${var.create_cloudwatch_log_group == true ? ["authenticator", "api"] : []}"
  enable_irsa                               = true
  cluster_endpoint_public_access            = true
  cluster_endpoint_private_access           = true
  manage_aws_auth_configmap                 = true 
  enable_kms_key_rotation                   = false 
  aws_auth_users                            = local.users
  cluster_addons = {
    # Uncomment if you want to upgarde the clusters addons, Its recommended to run it on the mentioned version.
    # Refer: https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html 
    coredns = {
      # most_recent                           = true
      preserve                              = true
      addon_version                         = "v1.10.1-eksbuild.2"
    }
    kube-proxy = {
      # most_recent                           = true
      preserve                              = true
      addon_version                         = "v1.27.3-eksbuild.1"
    }
    vpc-cni = {
      # most_recent                           = true
      preserve                              = true
      addon_version                         = "v1.13.2-eksbuild.1"
    }
  }
  eks_managed_node_group_defaults = {
    ami_type                                = var.core_node_group_configs.ami_type
    disk_size                               = var.core_node_group_configs.disk_size                                # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/0a17f655fb7da00640627ed9255f1d96e42fcfd7/modules/eks-managed-node-group/main.tf#L332s 
    subnet_ids                              = var.private_subnets_ids
    vpc_security_group_ids                  = var.security_group_ids  
    iam_role_additional_policies            = merge("${var.eks_additional_policies}",
                                                    {
                                                      AmazonEC2FullAccess                   = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
                                                      AmazonEC2ContainerRegistryFullAccess  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"      
                                                      AutoScalingFullAccess                 = "arn:aws:iam::aws:policy/AutoScalingFullAccess"   
                                                    })
  }
  eks_managed_node_groups = {   
    core-workers = {
      name                                  = local.core_workers_name
      max_size                              = var.core_node_group_configs.max_no_of_ec2
      min_size                              = var.core_node_group_configs.min_no_of_ec2
      desired_size                          = 1      
      capacity_type                         = var.core_node_group_configs.capacity_type
      ami_type                              = var.core_node_group_configs.ami_type
      instance_types                        = var.core_node_group_configs.instance_types                
      cpu_credits                           = "unlimited"       
      disk_size                             = var.core_node_group_configs.disk_size           # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/0a17f655fb7da00640627ed9255f1d96e42fcfd7/modules/eks-managed-node-group/main.tf#L332     
      public_ip                             = var.core_node_group_configs.public_ip      
      key_name                              = var.ssh_key_name      
      force_update_version                  = true
      create_launch_template                = true      
      metadata_http_put_response_hop_limit  = 2
      kubelet_extra_args                    = "--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`"
      ebs_optimized                         = true
      block_device_mappings                 = {
                                                xvda = {
                                                  device_name               = "/dev/xvda"
                                                  ebs = {
                                                    volume_size             = var.core_node_group_configs.disk_size
                                                    volume_type             = "gp3"
                                                    iops                    = 3000
                                                    throughput              = 150
                                                    delete_on_termination   = true
                                                  }
                                                }
                                              }       
      update_config                         = {
                                                max_unavailable_percentage  = 25
                                              }
      tags                                  = {
                                                workload                    = "core-workers"   
                                              }
    }, 
    app-workers = {
      name                                  = local.app_workers_name      
      max_size                              = var.app_node_group_configs.max_no_of_ec2
      min_size                              = var.app_node_group_configs.min_no_of_ec2
      desired_size                          = 1      
      capacity_type                         = var.app_node_group_configs.capacity_type      
      ami_type                              = var.app_node_group_configs.ami_type
      instance_types                        = var.app_node_group_configs.instance_types
      cpu_credits                           = "unlimited"       
      disk_size                             = var.app_node_group_configs.disk_size
      public_ip                             = var.app_node_group_configs.public_ip 
      key_name                              = var.ssh_key_name          
      force_update_version                  = true
      create_launch_template                = true      
      metadata_http_put_response_hop_limit  = 2
      kubelet_extra_args                    = "--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`,node.kubernetes.io/role=app-workers"
      ebs_optimized                         = true
      block_device_mappings                 = {
                                                xvda = {
                                                  device_name               = "/dev/xvda"
                                                  ebs = {
                                                    volume_size             = var.app_node_group_configs.disk_size
                                                    volume_type             = "gp3"
                                                    iops                    = 3000
                                                    throughput              = 150
                                                    encrypted               = true
                                                    delete_on_termination   = true
                                                  }
                                                }
                                              }         
      labels                                = merge( "${var.app_node_group_configs.labels}",
                                                    {
                                                      role                  = "app-workers"
                                                    })    
      taints                                = [merge( "${var.app_node_group_configs.taints}",
                                                    {
                                                      key                   = "role"
                                                      value                 = "app-workers"
                                                      effect                = "NO_SCHEDULE"
                                                    })]
      update_config                         = {
                                                max_unavailable_percentage  = 25
                                              }
      tags                                  = {
                                                workload                    = "app-workers"
                                              }
    }
  }
  cluster_tags                              = {
                                                workload                    = "eks-cluster"
                                              }   
}

# # Setting up the EKS cluster in your local system
resource "null_resource" "update_kubeconfig" {
  depends_on   = [module.eks_cluster ]
  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks_cluster.cluster_name} --profile ${var.aws_profile}"
  }
}
