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
  description     = "Whether to make db publicly accessible"
  default         = false
  type            = bool
  nullable        = false
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.database_public_access))
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

variable "db_log_retention_period" {
  type            = number
  default         = 7
  description     = "Performance insights retention period in days"
  nullable        = false
}

variable "vpc_id" {
  description     = "VPC id"
  type            = string
  nullable        = false
  validation {
    condition     = ( length(var.vpc_id) > 4 && substr(var.vpc_id, 0, 4) == "vpc-" )
    error_message = "The vpc id must start with \"vpc-\"."
  }
}

variable "private_subnets_ids" {
  description     = "Private subnets list to create database"
  default         = []
  type            = list(string)
  nullable        = false
  validation {
    condition     = (can([for id in var.private_subnets_ids : length(id) > 7 && substr(id, 0, 7) == "subnet-"]))
    error_message = "The subnet id must start with \"subnet-\"."
  }
}

variable "public_subnets_ids" {
  description     = "Public subnets list to create database"
  default         = []
  type            = list(string)
  nullable        = false
  validation {
    condition     = (can([for id in var.public_subnets_ids : length(id) > 7 && substr(id, 0, 7) == "subnet-"]))
    error_message = "The subnet id must start with \"subnet-\"."
  }
}

variable "security_group_ids" {
  description     = "List of Security group ids to associate with the database"
  default         = []
  type            = list(string)
  nullable        = true
  validation {
    condition     = alltrue([for id in var.security_group_ids : length(id) > 3 && substr(id, 0, 3) == "sg-"])
    error_message = "The security group id must start with \"sg-\"."
  }
}