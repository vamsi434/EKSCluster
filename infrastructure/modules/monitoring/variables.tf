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

variable "domain_name" {
  description     = "Domain name on which all the application will be hosted."  
  type            = string
  default         = ""
  nullable        = true   
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
