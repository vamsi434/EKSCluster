# Basic configurations
aws_region                      = "us-east-1"
prefix                          = "mle"
suffix                          = "infra"
vpc_ip_cidr                     = "10.55.0.0/16"
ssh_key_name                    = "ssh-key"
tags                            = {
                                     "project"     = "mle-infra-templates"
                                     "created_by"  = "mle-eks-infra-template"
                                   }  

# Bastion host configurations
bastion_host_ami                = "ami-026b57f3c383c2eec"
bastion_host_instance_type      = "t2.micro" 

# DNS and route53 configurations
domain_name                     = "eks.aws.apptemplates.tigeranalyticstest.in"
vpn_restriction                 = true
vpn_ips                         = [ "182.75.175.34","14.194.28.38" ]
ssl_certificates                = [
                                    "arn:aws:acm:us-east-1:198359301790:certificate/158553ed-2382-4d0d-a514-51c34d9694ac",
                                    "arn:aws:acm:us-east-1:198359301790:certificate/9f274e0f-6a46-4e5e-9da6-1381824fa875",
                                    "arn:aws:acm:us-east-1:198359301790:certificate/8db017ca-4275-4187-ad72-ca24f0a18dc8"
                                  ]

# Database configurations 
db_master_username              = "postgres"
max_acu_capacity                = 35
db_skip_final_snapshot          = true
enable_performance_insights     = true

# EKS configurations
eks_access_users                = [
                                    {
                                      "username"      = "rajarshee.basu@tigeranalytics.com",
                                      "cluster_role"  = "system:masters"
                                    },
                                    {
                                      "username"      = "abin.joseph@tigeranalytics.com",
                                      "cluster_role"  = "system:masters"
                                    },
                                    {
                                      "username"      = "aman.tandon@tigeranalytics.com",
                                      "cluster_role"  = "system:masters"
                                    },
                                  ] # For different types of cluster_role check this out: here https://kubernetes.io/docs/reference/access-authn-authz/rbac/
create_cloudwatch_log_group     = false 
core_node_group_configs         = {
                                    max_no_of_ec2      = 10
                                    instance_types     = ["t3a.medium"]
                                  } 
app_node_group_configs          = {
                                    max_no_of_ec2      = 30
                                    instance_types     = ["t3.medium","t3a.medium"] 
                                  }
eks_additional_policies         = {
                                    AmazonS3ReadOnlyAccess  = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  
                                  }                                