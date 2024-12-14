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

resource "aws_instance" "windows" {
  ami           = "ami-03cd80cfebcbb4481" # Windows Server 2022 Base
  instance_type = "t2.micro"
  key_name      = "terraform"
  vpc_security_group_ids = [aws_security_group.Grupo_de_Seguranca_Windows.id]
  subnet_id     = aws_subnet.Subrede_Publica.id
  associate_public_ip_address = true

  tags = {
    Name = "Windows_Instance"
  }
}
