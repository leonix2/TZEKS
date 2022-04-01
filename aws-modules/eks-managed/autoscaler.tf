provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.tzeks.token
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "tzeks" {
  name = module.eks.cluster_id
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
    name  = "extraArgs.scale-down-unneeded-time"
    value = "2m"
  }
    set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = "false"
  }
    set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "2m"
  }
  depends_on = [
    module.eks.cluster_id,
    null_resource.apply,
  ]
}

module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.12"

  role_name_prefix = "cluster-autoscaler"
  role_description = "IRSA role for cluster autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_id]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler-aws"]
    }
  }
}
