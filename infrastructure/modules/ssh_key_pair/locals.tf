locals {
  ssh_key_name                   = join("-", compact(["${var.prefix}","${var.ssh_key_name}","${var.suffix}"]))    
}