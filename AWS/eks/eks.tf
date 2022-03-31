locals {
  userdata =  base64encode( <<USERDATA
  #!/bin/bash
  set -ex
  /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.tzeks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.tzeks.certificate_authority.0.data}' '${aws_eks_cluster.tzeks.name}'
  USERDATA
  )
}


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

resource "aws_launch_template" "tzeks" {
  name          = "tzeks-node-group-lt"
  instance_type = "t3.small"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
    }
  }
  user_data = local.userdata 

  network_interfaces {
    associate_public_ip_address = true
  }

  image_id = data.aws_ami.image.id

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tzeks-nodegroup"
    }
  }

}

resource "aws_eks_cluster" "tzeks" {
  name     = "tzeks"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = false
    subnet_ids              = data.terraform_remote_state.network.outputs.public_subnets_ids
  }
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.tzeks.name
  node_group_name = "primary"
  node_role_arn   = aws_iam_role.node_group_primary.arn
  subnet_ids      = data.terraform_remote_state.network.outputs.public_subnets_ids
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }
  launch_template {
    id      = aws_launch_template.tzeks.id
    version = aws_launch_template.tzeks.latest_version
  }

  force_update_version = false
  labels = {
    type = "primary"
  }
  depends_on = [
    aws_iam_role_policy_attachment.aws_ec2_container_registry_read_only,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy
  ]
}
