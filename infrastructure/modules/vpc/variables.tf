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

variable "vpc_ip_cidr"{
  description     = "VPC IP CIDR Range."
  type            = string
  default         = "10.0.0.0/16" 
  nullable        = false  
  validation {
    condition     = can(cidrhost(var.vpc_ip_cidr, 32))
    error_message = "Must be valid IP CIDR."
  }         
}