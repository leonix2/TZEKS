module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tzeks"
  cidr = "10.200.0.0/16"
  

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets  = ["10.200.0.0/18", "10.200.64.0/18", "10.200.128.0/18"]

  public_subnet_tags = {
    "kubernetes.io/cluster/tzeks" = "shared"
    "kubernetes.io/role/elb"      = 1
  }

  tags = {
    Terraform = "true"
  }
}
