terraform {
  required_version = ">=1.6.0" # Versão do Terraform

  # Provedores Utilizados
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0" # Versão do AWS no Terraform
    }
  }
}

provider "aws" {
 region = "us-east-1"
 shared_config_files      = ["C:/Users/CRSCESAR/.aws/config"]
 shared_credentials_files = ["C:/Users/CRSCESAR/.aws/credentials"]
}

# Criar VPC
resource "aws_vpc" "vpc" {
 cidr_block = "193.16.0.0/16"

 tags = {
   name = "VPC_Crirar"
 }
}

# Criar Subrede Pública
resource "aws_subnet" "Subrede_Publica" {
 vpc_id     = aws_vpc.vpc.id
 cidr_block = "193.16.1.0/24"
}

# Criar Subrede Privada
resource "aws_subnet" "Subrede_Privada" {
 vpc_id     = aws_vpc.vpc.id
 cidr_block = "193.16.2.0/24"
}

# Criar Gateway de Internet 
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.vpc.id
}

# Criar Tabelade Rotas
resource "aws_route_table" "public" {
 vpc_id = aws_vpc.vpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
 }
}

# Associar  a subrede pública à tabela
resource "aws_route_table_association" "public" {
 subnet_id      = aws_subnet.Subrede_Publica.id
 route_table_id = aws_route_table.public.id
}

# Criar Grupo de Segurança Linux
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

# Criar Grupo de Segurança Windows
resource "aws_security_group" "Grupo_de_Seguranca_Windows" {
 name        = "grupowindows"
 description = "Allow rdp inbound traffic"
 vpc_id      = aws_vpc.vpc.id

 ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

# Criar EC2 Linux
resource "aws_instance" "linux" {
 ami           = "ami-058bd2d568351da34" # Debian 
 instance_type = "t2.micro"
 key_name      = "terraform" # Não esqueca de gerar a chave  pública e privada para este nome!
 vpc_security_group_ids = [aws_security_group.Grupo_de_Seguranca_LInux.id]
 subnet_id     = aws_subnet.Subrede_Publica.id
 associate_public_ip_address = true

 tags = {
    Name = "Linux_Instance"
 }
}

# Criar EC2 Windows
resource "aws_instance" "windows" {
 ami           = "ami-03cd80cfebcbb4481" # Windows Server 2022 Base
 instance_type = "t2.micro"
 key_name      = "terraform" # Não esqueca de gerar a chave  pública e privada para este nome!
 vpc_security_group_ids = [aws_security_group.Grupo_de_Seguranca_Windows.id]
 subnet_id     = aws_subnet.Subrede_Publica.id
 associate_public_ip_address = true

 tags = {
    Name = "Windows_Instance"
 }
}

# Criar o load balancer na AWS
resource "aws_lb" "loadb" {
  name               = "loadb"  # Nome do load balancer
  internal           = false    # Indica se o load balancer é interno ou externo
  load_balancer_type = "network"  # Tipo do load balancer, neste caso, é do tipo network
  subnets            = [aws_subnet.Subrede_Publica.id]  # Subnets onde o load balancer será provisionado
  enable_deletion_protection = false  # Desativa a proteção contra exclusão para o load balancer
}

# Criar o grupo de segurança para o load balancer
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"  # Nome do grupo de segurança
  description = "Grupo de Seguranca Loadb"  # Descrição do grupo de segurança
  vpc_id      = aws_vpc.vpc.id  # ID da VPC onde o grupo de segurança será criado

  # Regras de entrada permitindo tráfego HTTP (porta 80) e SSH (porta 22)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra de saída permitindo todo o tráfego
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Define como permitir todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Definindo o Grupo de destino para o load balancer
resource "aws_lb_target_group" "grupo_de_destino" {
  name     = "grupo"  # Nome do target group
  port     = 80       # Porta onde as instâncias estarão escutando
  protocol = "TCP"    # Protocolo utilizado
  vpc_id   = aws_vpc.vpc.id  # ID da VPC onde o target group será criado
}

# Definindo o listener para o load balancer
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.loadb.arn  # ARN do load balancer
  port              = 80                # Porta onde o listener estará escutando
  protocol          = "TCP"             # Protocolo utilizado

  default_action {
    type             = "forward"  # Ação padrão, encaminhar o tráfego para o target group
    target_group_arn = aws_lb_target_group.grupo_de_destino.arn  # ARN do target group
  }
}

# Criando  as instâncias EC2
resource "aws_instance" "Linuxlb" {
  count         = 2                              # Número de instâncias a serem criadas
  ami           = "ami-080e1f13689e07408"         # ID da AMI utilizada para criar as instâncias
  instance_type = "t2.micro"                      # Tipo de instância
  subnet_id     = aws_subnet.Subrede_Publica.id   # ID da subnet onde as instâncias serão criadas
  vpc_security_group_ids = [aws_security_group.lb_sg.id]  # IDs do grupo de segurança associados às instâncias
  associate_public_ip_address = true              # Associa um IP público às instâncias
  key_name = "terraform"                          # Nome da chave SSH utilizada para acessar as instâncias

  user_data = var.custom_data_script  # Script a ser executado na inicialização das instâncias

  tags = {
    Name = "Linux-${count.index}"  # Tags para identificação das instâncias
  }
}

# Associando as instâncias ao Grupo de destino 
resource "aws_lb_target_group_attachment" "grupo_target" {
  count            = 2                                # Número de instâncias a serem associadas
  target_group_arn = aws_lb_target_group.grupo_de_destino.arn    # ARN do target group
  target_id        = aws_instance.Linuxlb[count.index].id  # IDs das instâncias a serem associadas
  port             = 80                               # Porta onde as instâncias estarão escutando
}

# Definição do script de inicialização
variable "custom_data_script" {
  default = <<EOF
#!/bin/bash
#Atualizar os pacotes de instalação
sudo apt update -y
#Instalar o Apache2 e o Crontab
sudo apt install apache2 cron -y
#Habilitar a inicialização do Apache2 junto com o sistema
sudo systemctl enable apache2
#Iniciar o Apache2
sudo systemctl start apache2
#Criar script para colocar hostname no site
echo 'echo "Site na Maquina Virtual: $(hostname)" > /var/www/html/index.html' > /cron.sh
#Dar permissão de execução
chmod +x /cron.sh
#Jogar configuração de execução a todo minuto para o Crontab
echo '* * * * * root /cron.sh' > /etc/crontab
EOF
}
