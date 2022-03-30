networks = {
  tzeks = {
    vpc_cidr_block      = "10.200.0.0/16"
    public_subnet_cidrs = ["10.200.0.0/18", "10.200.64.0/18", "10.200.128.0/18"]
    availability_zone   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

    public_subnet_tags = {
      "service"                     = "eks"
      "kubernetes.io/cluster/tzeks" = "shared"
    }
  }
}
