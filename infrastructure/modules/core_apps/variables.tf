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

variable "tags" {
  description     = "All resources created from this code will be tagged with these values."   
  type            = map(string)
  default         = {}
  nullable        = true    
}

variable "domain_name" {
  description     = "Domain name on which all the application will be hosted."  
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

variable "cluster_name" {    
  description     = "Name of the eks cluster."  
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

variable "oidc_provider_arn" {
  description     = "ARN of the OIDC."  
  type            = string
  default         = ""
  nullable        = true       
}

variable "cluster_oidc_issuer_url" {
  description     = "EKS OIDC URL."  
  type            = string
  default         = ""
  nullable        = true       
} 

variable "nginx_annotations" {
  description     = "Annotations for ingress nginx."  
  type            = list(string)
  default         = []
  nullable        = true    
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