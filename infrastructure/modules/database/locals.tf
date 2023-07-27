locals {
  database_identifier               = join("-", compact(["${var.prefix}","database-cluster","${var.suffix}"]))   
  database_secret_name              = join("-", compact(["${var.prefix}","database-secrets","${var.suffix}"]))
  cluster_parameter_group_name      = join("-", compact(["${var.prefix}","database-cluster-parameter-groups","${var.suffix}"]))
  database_parameter_group_name     = join("-", compact(["${var.prefix}","database-parameter-groups","${var.suffix}"])) 
  database_subnet_group_name        = join("-", compact(["${var.prefix}","database-cluster-subnet-group","${var.suffix}"]))  
  database_subnets                  = "${var.database_public_access == true ? var.public_subnets_ids : var.private_subnets_ids }"   
}