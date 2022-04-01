provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.tzeks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.tzeks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.tzeks.token
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "tzeks" {
  name = aws_eks_cluster.tzeks.id
}

resource "helm_release" "cluster_autoscaler" {
  name             = "cluster-autoscaler"
  namespace        = "kube-system"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.10.8"
  create_namespace = false

  set {
    name  = "awsRegion"
    value = "eu-west-1"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler-aws"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa.iam_role_arn
    type  = "string"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = "tzeks"
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }
  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }
    set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = "false"
  }
    set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "2m"
  }
    set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "2m"
  }
  depends_on = [
    aws_eks_cluster.tzeks
  ]
}

module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.12"

  role_name_prefix = "cluster-autoscaler"
  role_description = "IRSA role for cluster autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [aws_eks_cluster.tzeks.id]

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider.arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler-aws"]
    }
  }
}


data "tls_certificate" "this" {
  url = aws_eks_cluster.tzeks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.tzeks.identity[0].oidc[0].issuer

}
