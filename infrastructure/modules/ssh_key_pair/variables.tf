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
