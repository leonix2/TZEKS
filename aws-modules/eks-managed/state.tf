#terraform {
#  backend "s3" {
#    bucket = "tfstate-tzeks"
#   key    = "terraform/tzeks/eks/terraform.tfstate"
#    region = "eu-west-1"
#  }
#}

#data "terraform_remote_state" "network" {
#  backend = "s3"
#  config = {
#    bucket = "tfstate-tzeks"
#    key    = "terraform/tzeks/network/terraform.tfstate"
#    region = "eu-west-1"
#  }
#}


terraform {
  backend "local" {
    path = "../../.terraform/tzeks/eks/terraform.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../../.terraform/tzeks/network/terraform.tfstate"
  }
}
