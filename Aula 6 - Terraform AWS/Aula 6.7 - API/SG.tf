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

resource "aws_security_group" "Grupo_de_Seguranca_LInux" {
  name        = "grupolinux"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "Grupo_de_Seguranca_Windows" {
  name        = "grupowindows"
  description = "Allow RDP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
