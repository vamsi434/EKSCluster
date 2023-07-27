/*************************
 Parameter Groups for RDS
**************************/
resource "aws_rds_cluster_parameter_group" "parameter_group" {
  name                = "${local.cluster_parameter_group_name}"
  family              = "aurora-postgresql14"
  tags   = {    
    workload          = "database"
  }   

  # These are just examples on how to add parameters  
  parameter {
    name              = "log_statement"
    value             = "none"
  }
  parameter {
    name              = "log_min_duration_statement"
    value             = "1000"
  } 
  parameter {
    apply_method      = "pending-reboot"
    name              = "max_connections"
    value             = "262143"
  }   
} 

resource "aws_db_parameter_group" "db_parameter_group" {
  name                = "${local.database_parameter_group_name}"
  family              = "aurora-postgresql14"
  tags   = {      
    workload          = "database"
  } 

  # This is just an example on how to add parameter  
  parameter {                                 
    apply_method      = "pending-reboot"
    name              = "max_connections"
    value             = "262143"
  }     
  
}

/*******************************************************************************
                                RDS Aurora Serverless
https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/8.0.2  
*********************************************************************************/
# Enable the data aws_secretsmanager_secret_version block if  manage_master_user_password is set to true
# Else ebable the resource random_password block

# data "aws_secretsmanager_secret_version" "db_secret" {
#   secret_id = module.aurora_postgresql_v2.cluster_master_user_secret.0.secret_arn
# }

resource "random_password" "master" {
  length                                = 20
  special                               = false
}

module "aurora_postgresql_v2" {
  source                                = "terraform-aws-modules/rds-aurora/aws"
  version                               = "8.0.2"
  name                                  = local.database_identifier
  port                                  = 5432
  engine                                = "aurora-postgresql"
  engine_mode                           = "provisioned"                                 # engine_mode should be set to provisioned for serverlessv2_scaling_configuration  refer: https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/8.0.2#input_serverlessv2_scaling_configuration          
  engine_version                        = "14.7"
  vpc_id                                = var.vpc_id
  vpc_security_group_ids                = var.security_group_ids
  db_subnet_group_name                  = local.database_subnet_group_name
  subnets                               = local.database_subnets 
  create_security_group                 = false
  auto_minor_version_upgrade            = false
  manage_master_user_password           = false   
  create_db_subnet_group                = true
  apply_immediately                     = true      
  storage_encrypted                     = true 
  copy_tags_to_snapshot                 = true
  database_name                         = "postgres"
  master_username                       = var.db_master_username
  master_password                       = random_password.master.result  
  publicly_accessible                   = var.database_public_access  
  skip_final_snapshot                   = var.db_skip_final_snapshot  
  db_parameter_group_name               = aws_db_parameter_group.db_parameter_group.name
  db_cluster_parameter_group_name       = aws_rds_cluster_parameter_group.parameter_group.name
  # Enhanced monitoring and logging
  performance_insights_enabled          = var.enable_performance_insights  
  monitoring_interval                   = var.db_monitoring_interval 
  create_monitoring_role                = true 
  performance_insights_retention_period = var.db_log_retention_period
  # Serverless Configuration                                                              refer: https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/8.0.2#:~:text=%3D%20%22db.r6g.large%22-,instances%20%3D%20%7B,-one%20%3D%20%7B%7D%0A%20%20%20%202
  instance_class                        = "db.serverless"
  instances = {
    one = {
        identifier                      = "${local.database_identifier}-one"
    }
    # two = {}
  }
  serverlessv2_scaling_configuration = {
    min_capacity                        = var.min_acu_capacity
    max_capacity                        = var.max_acu_capacity
  }     
  tags   = {    
    workload                            = "database"
  }  
}

# Aws Secrect manager for Database Credentaials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name                                  = "${local.database_secret_name}"
  description                           = "Credentials of database."
  tags   = {    
    workload                            = "database"
  }   
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {  
  secret_id                             = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
  {
    "username": "${module.aurora_postgresql_v2.cluster_master_username}",
    "password": "${module.aurora_postgresql_v2.cluster_master_password}",
    "engine": "aurora-postgresql",
    "host": "${module.aurora_postgresql_v2.cluster_endpoint}",
    "port": ${module.aurora_postgresql_v2.cluster_port},
    "dbClusterIdentifier": "${local.database_identifier}"
  }
  EOF  
}
  # Add this to the above segment if manage_master_user_password is set to true
  # "password": "${jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["password"]}",