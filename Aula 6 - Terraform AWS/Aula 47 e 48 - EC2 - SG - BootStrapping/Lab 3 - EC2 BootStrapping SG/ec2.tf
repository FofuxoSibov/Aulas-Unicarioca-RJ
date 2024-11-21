###### GRUPO DE SERGURANÇA ######
resource "aws_security_group" "Grupo-Sec-Linux" {
  name        = "Grupo-Sec-Linux"
  description = "Liberar entrada SSH, HTTP e PING"
  vpc_id      = "vpc-00d6012d60a7255b0" # Trocar para o ID da sua VPC

  #Liberar porta SSH de Entrada
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Liberar porta HTTP de Entrada
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Liberar Ping de Entrada
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Liberar saida do pacote
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########### EC2 ###########
data "template_file" "user_data" {
  template = file("./scripts/site_aws.sh")
}

resource "aws_instance" "Linux" {
  ami                         = "ami-0d7a109bf30624c99"    #AMI Amazon Linux 2
  instance_type               = "t2.micro"                 # Tipo de maquina
  subnet_id                   = "subnet-0fac1f1baf7c67c24" #alterar subnet Publica 1
  key_name                    = "Terraform"                #alterar da sua chave
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.Grupo-Sec-Linux.id]
  user_data                   = base64encode(data.template_file.user_data.rendered)

  tags = {
    Name = "Linux-Terraform-02"
  }
}

output "instance_public_ip" {
  description = "IP Publico da Instancia EC2"
  value       = aws_instance.Linux.public_ip
}
