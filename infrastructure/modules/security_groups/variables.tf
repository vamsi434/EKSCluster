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

variable "vpc_id" {
  description     = "ID of the VPC in which the security groups will be created."
  type            = string
  default         = "" 
  nullable        = false
  validation {
    condition     = ( length(var.vpc_id) > 4 && substr(var.vpc_id, 0, 4) == "vpc-" )
    error_message = "The vpc id must start with \"vpc-\"."
  }
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
