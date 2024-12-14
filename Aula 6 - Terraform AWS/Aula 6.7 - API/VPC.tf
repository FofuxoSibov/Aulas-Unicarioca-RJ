terraform {
  required_version = ">=1.6.0" # Versão do Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0" # Versão do AWS no Terraform
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  shared_config_files      = ["C:/Users/CRSCESAR/.aws/config"]
  shared_credentials_files = ["C:/Users/CRSCESAR/.aws/credentials"]
}

resource "aws_vpc" "vpc" {
  cidr_block = "193.16.0.0/16"

  tags = {
    name = "VPC_Crirar"
  }
}

resource "aws_subnet" "Subrede_Publica" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "193.16.1.0/24"
}

resource "aws_subnet" "Subrede_Privada" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "193.16.2.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.Subrede_Publica.id
  route_table_id = aws_route_table.public.id
}

