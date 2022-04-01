data "aws_ssm_parameter" "image_id" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/image_id"
}

data "aws_ami" "image" {
  owners = ["amazon"]
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.image_id.value]
  }
}

module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v18.7.2"

  cluster_name                    = "tzeks"
  cluster_version                 = var.kubernetes_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true


  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.public_subnets_ids

  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  self_managed_node_groups = {

    public = {
      name            = "public-self-mng"
      use_name_prefix = false

      subnet_ids = data.terraform_remote_state.network.outputs.public_subnets_ids

      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_refresh = {
        strategy = "Rolling"
        preferences = {
          checkpoint_delay       = 600
          checkpoint_percentages = [35, 70, 100]
          instance_warmup        = 300
          min_healthy_percentage = 50
        }
        triggers = ["tag"]
      }

      ami_id               = data.aws_ami.image.id
      bootstrap_extra_args = "--kubelet-extra-args '--max-pods=11'"

      pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT

      disk_size     = 30
      instance_type = "t3.small"

      launch_template_name            = "tzeks-self-managed-lt"
      launch_template_use_name_prefix = true
      launch_template_description     = "TZEKS Self managed node group launch template"

      ebs_optimized     = true
      enable_monitoring = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 30
            volume_type = "gp2"
          }
        }
      }

      create_iam_role          = true
      iam_role_name            = "self-managed-node-group-tzeks"
      iam_role_use_name_prefix = false
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]

      create_security_group          = false
      security_group_use_name_prefix = false

      tags = {
        "k8s.io/cluster-autoscaler/tzeks"   = "owned"
        "k8s.io/cluster-autoscaler/enabled" = "true"
      }
    }
  }

}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}

resource "null_resource" "apply" {
  triggers = {
    kubeconfig = base64encode(local.kubeconfig)
    cmd_patch  = <<-EOT
      kubectl create configmap aws-auth -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl patch configmap/aws-auth --patch "${module.eks.aws_auth_configmap_yaml}" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_patch
  }
}
