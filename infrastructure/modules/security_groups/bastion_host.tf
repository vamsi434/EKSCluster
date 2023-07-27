/*********************************
  Security group for bastion host
**********************************/
module "bastion_host_sg" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "4.17.2"  
  name            = "${local.bastion_host_sg_name}"
  description     = "Security group for bastion host"
  vpc_id          = var.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "For SSH"
      cidr_blocks = "${local.vpn_ips}"
    },   
  ]
  egress_with_cidr_blocks  = [
    {
      from_port   = 0
      to_port     = 0
      type        = "All traffic"
      protocol    = "All"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = {
    workload      = "security-groups"
  }
}
