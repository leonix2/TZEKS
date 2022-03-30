resource "aws_eks_cluster" "tzeks" {
  name     = "tzeks"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = false
    subnet_ids = data.terraform_remote_state.network.aws_subnet.tzeks_public.id
  }
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "primary" {
  cluster_name    = aws_eks_cluster.helloworld.name
  node_group_name = "primary"
  node_role_arn   = aws_iam_role.node_group_primary.arn
  subnet_ids = data.terraform_remote_state.network.aws_subnet.tzeks_public.id
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }
  ami_type             = "AL2_x86_64"
  capacity_type        = "SPOT"
  disk_size            = 30
  force_update_version = false
  instance_types       = ["t3.small"]
  labels = {
    type = "primary"
  }
  depends_on = [
    aws_iam_role_policy_attachment.aws_ec2_container_registry_read_only,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy
  ]
}
