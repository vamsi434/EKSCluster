locals {
  bastion_name                   = join("-", compact(["${var.prefix}","bastion-host","${var.suffix}"]))    
}