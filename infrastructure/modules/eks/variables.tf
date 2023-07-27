variable "prefix" {
  description     = "It will be the value that will be added before all resources name."
  type            = string
  default         = ""   
  nullable        = true 
}

variable "suffix" {
  description     = "It will be the value that will be added after all resources name."
  type            = string
  default         = "" 
  nullable        = true
}

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

variable "aws_profile" {
  description     = "Your local AWS profile name."  
  type            = string
  default         = "default"
  nullable        = false    
}


variable "vpc_id" {
  description     = "ID of the VPC in which the security groups will be created."
  type            = string
  default         = "" 
  nullable        = false
  validation {
    condition     = ( length(var.vpc_id) > 4 && substr(var.vpc_id, 0, 4) == "vpc-")
    error_message = "The vpc id must start with \"vpc-\"."
  }
}

variable "eks_access_users" {
  description     = "Users who will have access to EKS cluster."  
  type            = list(map(string))
  default         = [{}]
  nullable        = true    
}

variable "security_group_ids" {
  description     = "List of Security group Ids."  
  type            = list(string)
  default         = []
  nullable        = false      
  validation {
    condition     = alltrue([for id in var.security_group_ids : length(id) > 3 && substr(id, 0, 3) == "sg-"])
    error_message = "The security group id must start with \"sg-\"."
  }
}

variable "ssh_key_name"{
  description     = "SSH key used for remote communication with EKS EC2."
  type            = string
  default         = "eks-infra-key" 
  nullable        = true  
  validation {
    condition     = length(var.ssh_key_name) >= 3
    error_message = "Must be valid key name of minimum length 3 characters."
  }      
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

variable "private_subnets_ids" {
  description     = "Private sbubnets of the VPC."  
  type            = list(string)
  default         = [""]
  nullable        = false
  validation {
    condition     = (can([for id in var.private_subnets_ids : length(id) > 7 && substr(id, 0, 7) == "subnet-"]))
    error_message = "The subnet id must start with \"subnet-\"."
  }
}

variable "public_subnets_ids" {
  description     = "Public sbubnets of the VPC."  
  type            = list(string)
  default         = [""]
  nullable        = false 
  validation {
    condition     = (can([for id in var.public_subnets_ids : length(id) > 7 && substr(id, 0, 7) == "subnet-"]))
    error_message = "The subnet id must start with \"subnet-\"."
  }
}

variable "eks_additional_policies" {
  description     = "IAM Policies attched to the node groups."  
  type            = map(string)
  default         = {}
  nullable        = false      
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