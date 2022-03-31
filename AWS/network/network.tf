resource "aws_vpc" "tzeks" {
  cidr_block                       = var.network.tzeks.vpc_cidr_block
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "tzeks"
  }
}

resource "aws_subnet" "tzeks_public" {
  count                   = length(var.network.tzeks.public_subnet_cidrs)
  vpc_id                  = aws_vpc.tzeks.id
  cidr_block              = element(var.network.tzeks.public_subnet_cidrs, count.index)
  availability_zone       = element(var.network.tzeks.availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/tzeks" = "shared"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.tzeks.id
}

resource "aws_route_table" "tzeks_public" {
  count  = length(var.network.tzeks.public_subnet_cidrs)
  vpc_id = aws_vpc.tzeks.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "tzeks_public" {
  count          = length(var.network.tzeks.public_subnet_cidrs)
  route_table_id = element(aws_route_table.tzeks_public[*].id, count.index)
  subnet_id      = element(aws_subnet.tzeks_public[*].id, count.index)
}


