terraform {
  required_version = ">= 1.6.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = ["C:/Users/admin/.aws/config"]
  shared_credentials_files = ["C:/Users/admin/.aws/credentials"]

  default_tags {
    tags = {
      owner      = "fernando"
      managed-by = "terraform"
    }
  }

}