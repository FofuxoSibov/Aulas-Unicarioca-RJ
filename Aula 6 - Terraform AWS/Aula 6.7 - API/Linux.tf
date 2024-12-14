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

resource "aws_instance" "Linuxlb" {
  count         = 2
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Subrede_Publica.id
  vpc_security_group_ids = [aws_security_group.lb_sg.id]
  associate_public_ip_address = true
  key_name = "terraform"

  user_data = var.custom_data_script

  tags = {
    Name = "Linux"
  }
}

# Arquivo: variables.tf
variable "custom_data_script" {
  default = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install apache2 cron -y
sudo systemctl enable apache2
sudo systemctl start apache2
echo 'echo "Site na Maquina Virtual: $(hostname)" > /var/www/html/index.html' > /cron.sh
chmod +x /cron.sh
echo '* * * * * root /cron.sh' > /etc/crontab
EOF
}