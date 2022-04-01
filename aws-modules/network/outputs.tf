output "vpc_id" {
  description = "VPC for EKS"
  value       = module.vpc.vpc_id
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets[*]
  # value       = {for k,v in module.vpc : k => v.public_subnet_ids}
}
