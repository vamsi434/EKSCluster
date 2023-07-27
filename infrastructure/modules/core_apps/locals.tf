locals{
  ssl_value                         = length(var.ssl_certificates) == 0  ? "service.beta.kubernetes.io/aws-load-balancer-type: external" : "service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${join(",", "${var.ssl_certificates}")}"
  load_balancer_scheme              = var.enable_internet_facing_lb == true ? "internet-facing" : "internal"
  cluster_autoscaler_iam_role_name  = join("-", compact(["${var.prefix}","cluster-autoscaler-role","${var.suffix}"]))
  aws_lb_controller_iam_policy_name = join("-", compact(["${var.prefix}","aws-load-balancer-controller-policy","${var.suffix}"]))  
  aws_lb_controller_iam_role_name   = join("-", compact(["${var.prefix}","aws-load-balancer-controller-role","${var.suffix}"])) 
  ingress_tags                      = join(",", [for key, value in merge( {workload="ingress"}, var.tags ) : "${key}=${value}"])  
  ebs_volume_tags                   = join("\n",[for key, value in merge( {"Name":"${var.cluster_name}"},{workload:"eks-ebs"}, var.tags ) : "    ${key}: ${value}"]) //Don't remove the extra space infront of key
}