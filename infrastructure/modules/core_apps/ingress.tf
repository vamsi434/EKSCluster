/********************************************************************************************************************
                                AWS Load Balancer Controller For Ingress Nginx
              https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
IAM Policy:   https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/v2.5.4/docs/install/iam_policy.json
*********************************************************************************************************************/

# # IAM Role Policy for aws-load-balancer-controller
data "aws_iam_policy_document" "aws_lb_controller_role_policy" {
  statement {
    actions           = ["sts:AssumeRoleWithWebIdentity"]
    effect            = "Allow"
    condition {
      test            = "StringEquals"
      variable        = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values          = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    principals {
      identifiers     = ["${var.oidc_provider_arn}"]
      type            = "Federated"
    }
  } 
}

resource "aws_iam_policy" "aws_lb_controller_policy" {
  name                = "${local.aws_lb_controller_iam_policy_name}"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "StringEquals": {
                    "elasticloadbalancing:CreateAction": [
                        "CreateTargetGroup",
                        "CreateLoadBalancer"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },        
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup",
                "ec2:CreateSecurityGroup",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "ec2:RevokeSecurityGroupIngress",
                "elasticloadbalancing:AddListenerCertificates", 
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup", 
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyListener",                
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",                
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:RemoveListenerCertificates",
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:CreateServiceLinkedRole",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"              
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role" "aws_lb_controller_iam_role" {
  name                = "${local.aws_lb_controller_iam_role_name}"
  assume_role_policy  = "${data.aws_iam_policy_document.aws_lb_controller_role_policy.json}"
  managed_policy_arns = [aws_iam_policy.aws_lb_controller_policy.arn]
  tags   = {    
    workload          = "ingress"
  }   
}

# # Installing aws-load-balancer-controller refer https://github.com/aws/eks-charts/pull/968
resource "helm_release" "aws_lb_controller" {
  depends_on          = [ aws_iam_role.aws_lb_controller_iam_role ]    
  name                = "aws-load-balancer-controller"
  repository          = "https://aws.github.io/eks-charts"
  chart               = "aws-load-balancer-controller"
  version             = "1.5.4"
  namespace           = "kube-system"
  atomic              = true  
  timeout             = 300
  values              = [
    <<EOT
replicaCount: 1 
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.aws_lb_controller_iam_role.arn}
  name: aws-load-balancer-controller
  automountServiceAccountToken: true 

resources:
  requests:
    cpu: 30m
    memory: 256Mi

clusterName: ${var.cluster_name}    
  EOT
  ]
}

/**********************************************************************************************************************************************
                                              Ingress Nginx
                https://github.com/kubernetes/ingress-nginx/tree/helm-chart-4.7.0                
Configurations: https://github.com/kubernetes/ingress-nginx/blob/main/hack/manifest-templates/provider/aws/nlb-with-tls-termination/values.yaml
Annotations:    https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/service/annotations/      
***********************************************************************************************************************************************/

# # Installation of Ingress Nginx
resource "helm_release" "ingress_nginx" {
  depends_on        = [helm_release.aws_lb_controller]  
  name              = "ingress-nginx"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  version           = "4.7.0"
  namespace         = "ingress-nginx"
  create_namespace  = true  
  atomic            = true  
  timeout           = 300
  values            = [
    <<EOT
controller:
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-attributes: load_balancing.cross_zone.enabled=true
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
      service.beta.kubernetes.io/aws-load-balancer-scheme: ${local.load_balancer_scheme}
      service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: ${local.ingress_tags}
      ${local.ssl_value}
      ${join("\n      ","${var.nginx_annotations}")}
    targetPorts:
      http: tohttps
      https: http
  containerPort:
    http: 80
    https: 80
    tohttps: 2443
  metrics:
    enabled: true
    serviceMonitor:
      enabled: false
    service:
      annotations: 
        prometheus.io/scrape: "true"
        prometheus.io/port: "10254"
  config:
    proxy-real-ip-cidr: ${var.vpc_ip_cidr}
    use-forwarded-headers: "true"
    http-snippet: |
      server {
        listen 2443;
        return 308 https://\$host\$request_uri;
      }        
  resources:
    requests:
      cpu: 30m
      memory: 256Mi
  EOT
  ]
}

/*
loadBalancerSourceRanges: [list of IPs] # Add this under controller.service if we want to restrict the load balancer to a cretain ips directly.
NOTE: It will be applied across  the cluster, and all URLs will be affected. 
*/

data "kubernetes_service" "nginx_ingress" {
  depends_on = [helm_release.ingress_nginx]
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}