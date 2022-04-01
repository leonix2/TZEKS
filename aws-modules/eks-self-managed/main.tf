provider "aws" {
  region = "eu-west-1"
}

provider "kubernetes" {
  load_config_file = false
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0"
    }
  }
}
