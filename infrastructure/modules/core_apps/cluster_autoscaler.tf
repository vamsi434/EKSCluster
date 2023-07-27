/***********************************************************************************************
                                    Cluster Autoscaler
https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-chart-9.28.0/cluster-autoscaler   
*************************************************************************************************/

# # IAM Role Policy for cluster-autoscaler
data "aws_iam_policy_document" "cluster_autoscaler_role_policy" {
  statement {
    actions           = ["sts:AssumeRoleWithWebIdentity"]
    effect            = "Allow"
    condition {
      test            = "StringEquals"
      variable        = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values          = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
    principals {
      identifiers     = ["${var.oidc_provider_arn}"]
      type            = "Federated"
    }
  } 
}

resource "aws_iam_role" "cluster_autoscaler_iam_role" {
  assume_role_policy  = "${data.aws_iam_policy_document.cluster_autoscaler_role_policy.json}"
  name                = "${local.cluster_autoscaler_iam_role_name}"
  tags   = {    
      workload        = "cluster-autoscaler"
  } 
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_iam_policy_attach" {
  policy_arn          = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role                = aws_iam_role.cluster_autoscaler_iam_role.name
}

# # Installation of Cluster Autoscaler
resource "helm_release" "cluster_autoscaler" {
  name                = "cluster-autoscaler"
  namespace           = "kube-system"
  chart               = "cluster-autoscaler"
  repository          = "https://kubernetes.github.io/autoscaler"
  version             = "9.28.0"
  atomic              = true
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  values = [
    <<EOT
extraArgs:
  logtostderr: true
  stderrthreshold: info
  v: 4
  expander: least-waste
  balance-similar-node-groups: true
  skip-nodes-with-local-storage: false
fullnameOverride: "cluster-autoscaler"
rbac:
  create: true
  pspEnabled: false
  clusterScoped: true
  serviceAccount:
    annotations: 
      eks.amazonaws.com/role-arn: ${aws_iam_role.cluster_autoscaler_iam_role.arn}
    name: cluster-autoscaler
    automountServiceAccountToken: true
resources:
 requests:
   cpu: 10m
   memory: 128Mi
  EOT
  ]
}