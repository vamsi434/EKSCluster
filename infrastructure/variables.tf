# Basic configurations
variable "aws_region" {
  description     = "AWS Region"
  type            = string
  default         = "us-east-1" 
  nullable        = false  
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "Must be valid AWS Region names."
  }  
}


variable "prefix" {
  description     = "It will be the value that will be added before all resources name."
  type            = string
  default         = ""   
  nullable        = true
  validation {
    condition     = length(var.prefix) <= 12
    error_message = "Prefix lenght can be maximum of 12 characters."
  }     
}

variable "suffix" {
  description     = "It will be the value that will be added after all resources name."
  type            = string
  default         = "" 
  nullable        = true
}

variable "vpc_ip_cidr" {
  description     = "VPC IP CIDR Range."
  type            = string
  default         = "10.0.0.0/16" 
  nullable        = false  
  validation {
    condition     = can(cidrhost(var.vpc_ip_cidr, 0))
    error_message = "Must be valid IP CIDR."
  }     
}

variable "ssh_key_name"{
  description     = "SSH key used for remote communication with EKS EC2."
  type            = string
  default         = "mle-infra-template-key" 
  nullable        = true  
  validation {
    condition     = length(var.ssh_key_name) >= 3
    error_message = "Must be valid key name of minimum length 3 characters."
  }    
}

variable "aws_profile" {
  description     = "Your local AWS profile name."  
  type            = string
  default         = "default"
  nullable        = false    
}

variable "tags" {
  description     = "All resources created from this code will be tagged with these values."   
  type            = map(string)
  default         = {}
  nullable        = true
}

# Bastion host configurations
variable "bastion_host_ami" {
  description     = "AMI for Bastion Host(EC2)."
  type            = string
  default         = "ami-026b57f3c383c2eec" 
  nullable        = false     
  validation {
    condition     = ( length(var.bastion_host_ami) > 4 && substr(var.bastion_host_ami, 0, 4) == "ami-")
    error_message = "The bastion_host_ami value must start with \"ami-\"."
  }
}

variable "bastion_host_instance_type" {
  description     = "Instance type for Bastion Host(EC2)."
  type            = string
  default         = "t2.micro" 
  nullable        = false     
}

variable "bastion_host_public_access" {
  description     = "The bastion host(EC2) should be VPN-protected or not."   
  type            = bool
  default         = true
  nullable        = false    
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$",var.bastion_host_public_access))
    error_message = "The bastion_host_public_access must be either true or false."
  }  
}

# DNS and route53 configurations
variable "domain_name"{
  description     = "Domain name on which all the application will be hosted."  
  type            = string
  default         = ""
  nullable        = true  
  # validation {
  #   condition     = can(regex("^(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][a-zA-Z0-9-_]{1,61}[a-zA-Z0-9])).([a-zA-Z]{2,6}|[a-zA-Z0-9-]{2,30}.[a-zA-Z]{2,3})$", var.domain_name))
  #   error_message = "Must be valid domain name."
  # }    
}

variable "vpn_restriction" {
  description     = "The application should be VPN-protected or not."    
  type            = bool  
  default         = true
  nullable        = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$",var.vpn_restriction))
    error_message = "The vpn_restriction must be either true or false."
  }  
}

variable "vpn_ips"{
  description     = "Domain name on which all the  applications will be hosted."  
  type            = list(string)
  default         = ["0.0.0.0"]
  nullable        = true    
  validation {
    condition     = can([for ip in var.vpn_ips: regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip)])
    error_message = "Invalid IP address provided."
  }    
}

variable "enable_internet_facing_lb"{
  description     = "Specifies whether the NLB will be internet-facing or internal. Valid values are true or false. If not specified, default is true."  
  type            = bool
  default         = true
  nullable        = false    
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$",var.enable_internet_facing_lb))
    error_message = "The enable_internet_facing_lb must be either true or false."
  }   
}

variable "ssl_certificates" {
  description     = "List of SSL certificates for the different sites."  
  type            = list(string)
  default         = []
  nullable        = true    
  validation {
    condition     = can([for ip in var.ssl_certificates : regex("^arn:aws:acm:[a-z][a-z]-[a-z]+-[1-9]:\\d{12}:certificate\\/[A-Za-z0-9]+(?:-[A-Za-z0-9]+)+$", ip)])
    error_message = "Invalid SSL ARNs."
  }    
}

variable "nginx_annotations" {
  description     = "Annotations for ingress nginx."  
  type            = list(string)
  default         = []
  nullable        = true    
}

# Database configurations 
variable "db_master_username" {
  description     = "DB master username"
  default         = "postgres"
  type            = string
  nullable        = false
}

variable "max_acu_capacity" {
  description     = "Maximum number of ACU for database."
  default         = 10
  type            = number
  nullable        = false
  validation {
    condition     = var.max_acu_capacity >= 1 && var.max_acu_capacity <= 128
    error_message = "Value should be in range [1-128] and should be a integer."
  }
}

variable "min_acu_capacity" {
  description     = "Minimum number of ACU for database."
  default         = 0.5
  type            = number
  nullable        = false
  validation {
    condition     = var.min_acu_capacity >= 0.5 && var.min_acu_capacity <= 128
    error_message = "The min_acu_capacity should be in range [0.5-128]."
  }
}

variable "database_public_access" {
  description     = "The database should be publicly accessible or not."   
  type            = bool
  default         = false
  nullable        = false    
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$",var.database_public_access))
    error_message = "The database_public_access must be either true or false."
  }  
}

variable "db_monitoring_interval" {
  description     = "DB monitoring interval"
  default         = 30
  type            = number
  nullable        = false
}

variable "db_skip_final_snapshot" {
  description     = "Whether to skip db final snapshot"
  default         = true
  type            = bool
  nullable        = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.db_skip_final_snapshot))
    error_message = "The db_skip_final_snapshot must be either true or false."
  }
}

variable "enable_performance_insights" {
  type            = bool
  default         = true
  description     = "Whether to enable performance insights"
  nullable        = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.enable_performance_insights))
    error_message = "The performance_insights_enabled must be either true or false."
  }
}

variable "performance_insights_retention_period" {
  type            = number
  default         = 7
  description     = "Performance insights retention period in days"
  nullable        = false
}

# Variables for EKS modules
variable "eks_access_users" {
  description     = "Users who will have access to EKS cluster."  
  type            = list(map(string))
  default         = [{}]
  nullable        = true    
}

variable "eks_additional_policies" {
  description     = "IAM Policies attched to the node groups."  
  type            = map(string)
  default         = {}
  nullable        = false      
}

variable "create_cloudwatch_log_group" {
  description     = "To enable and disable the creation of EKS Cloudwatch log group."   
  type            = bool
  default         = false
  nullable        = false    
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$",var.create_cloudwatch_log_group))
    error_message = "The vpn_restriction must be either true or false."
  }  
}

variable "core_node_group_configs" {
  # Referred from: https://developer.hashicorp.com/terraform/language/expressions/type-constraints#example-nested-structures-with-optional-attributes-and-defaults
  description       = "To enable and disable the creation of EKS Cloudwatch log group."   
  nullable          = false 
  type =  object({
    max_no_of_ec2   = optional(number, 10)
    min_no_of_ec2   = optional(number, 1)    
    ami_type        = optional(string, "AL2_x86_64")
    capacity_type   = optional(string, "ON_DEMAND")
    instance_types  = optional(list(string), ["t3a.medium"])
    disk_size       = optional(number, 20)
    public_ip       = optional(bool, false)
   })
}

variable "app_node_group_configs" {
  # Referred from: https://developer.hashicorp.com/terraform/language/expressions/type-constraints#example-nested-structures-with-optional-attributes-and-defaults
  description       = "To enable and disable the creation of EKS Cloudwatch log group."   
  nullable          = false 
  type =  object({
    max_no_of_ec2   = optional(number, 30)
    min_no_of_ec2   = optional(number, 1)
    ami_type        = optional(string, "AL2_x86_64")
    capacity_type   = optional(string, "ON_DEMAND")
    instance_types  = optional(list(string), ["t3a.medium"])
    disk_size       = optional(number, 20)
    public_ip       = optional(bool, false)
    labels          = optional(map(string),{} )
    taints          = optional(map(string),{} )
   })
}