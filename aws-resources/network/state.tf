#terraform {
#  backend "s3" {
#    bucket = "tfstate-tzeks"
#    key    = "terraform/tzeks/network/terraform.tfstate"
#    region = "eu-west-1"
#  }
#}

terraform {
  backend "local" {
    path = "../../.terraform/tzeks/network/terraform.tfstate"
  }
}
