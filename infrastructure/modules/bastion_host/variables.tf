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

variable "instance_type" {
  description     = "Instance type for Bastion Host(EC2)."
  type            = string
  default         = "t2.micro" 
  nullable        = false     
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

variable "subnet_id"{
  description     = "Sbubnet on which it will be hosted."  
  type            = string
  default         = ""
  nullable        = false
}

variable "security_group_ids" {
  description     = "List of Security Group Ids."  
  type            = list(string)
  default         = []
  nullable        = false      
  validation {
    condition     = alltrue([for id in var.security_group_ids : length(id) > 3 && substr(id, 0, 3) == "sg-"])
    error_message = "The security group id must start with \"sg-\"."
  }
}
