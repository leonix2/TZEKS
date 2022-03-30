output "vpc_id" {
  description = "VPC for EKS"
  value       = aws_vpc.tzeks.id
}

output "public_subnets_cidrs" {
  description = "List of IDs of public subnets"
  value = aws_subnet.tzeks_public.id
}
