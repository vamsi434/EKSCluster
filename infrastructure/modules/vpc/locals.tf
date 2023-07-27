locals {
  vpc_name                   = join("-", compact(["${var.prefix}","vpc","${var.suffix}"]))
  cluster_name               = join("-", compact(["${var.prefix}","eks","${var.suffix}"]))   
}