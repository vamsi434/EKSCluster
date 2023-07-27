locals {
  self_reference_sg_name     = join("-", compact(["${var.prefix}","self-reference-sg","${var.suffix}"]))
  bastion_host_sg_name       = join("-", compact(["${var.prefix}","bastion-host-sg","${var.suffix}"]))  
  vpn_ips                    = "${var.bastion_host_public_access == true ?  "0.0.0.0/0" : join(",", ["${join(",", [for ips in var.vpn_ips : format("%s/32", ips)])}"])}" 
}