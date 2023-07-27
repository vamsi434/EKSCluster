/*********************************
  Self referencing security group
**********************************/
module "self_reference_sg" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "4.17.2"  
  name            = "${local.self_reference_sg_name}"
  description     = "Self referencing security group"
  vpc_id          = var.vpc_id
  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Self referencing security group ingress"
      self        = true
    },   
  ]
  egress_with_self  = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Self referencing security group egress"      
      self        = true
    },
  ]
  tags = {
    workload      = "security-groups"
  }
}
