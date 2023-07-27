/********************
  Bastion Host Setup
*********************/
module "bastion_host" {
  source                    = "terraform-aws-modules/ec2-instance/aws"
  version                   = "5.0.0"
  name                      = local.bastion_name
  ami                       = var.bastion_host_ami
  instance_type             = var.instance_type
  key_name                  = var.ssh_key_name
  vpc_security_group_ids    = var.security_group_ids
  subnet_id                 = var.subnet_id 
  monitoring                = true
  enable_volume_tags        = false  
  tags = {
    workload                = "bastion-host"       
    Name                    = "${local.bastion_name}"
  }
}

/******************
  Elastic IP Setup
*******************/
resource "aws_eip" "bastion_host" {
  instance                  = module.bastion_host.id
  vpc                       = true
  tags = {
    workload                = "bastion-host"
    Name                    = "${local.bastion_name}-eip"
  }
}

