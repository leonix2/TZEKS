output "asg_name" {
  description = "NodeGroup ASG ID"
  value       = aws_eks_node_group.primary.resources[*].autoscaling_groups[*].name
}
