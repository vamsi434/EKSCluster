locals {
  loki_logs_bucket           = join("-", compact(["${var.prefix}","loki-logs","${var.suffix}"])) 
  grafana_secret             = join("-", compact(["${var.prefix}","grafana-credentials","${var.suffix}"]))      
  vpn_ips                    = "${var.vpn_restriction == true ? join(",", ["${join(",", [for ips in var.vpn_ips : format("%s/32", ips)])}","${var.vpc_ip_cidr}"]) : "0.0.0.0/0"}"
}