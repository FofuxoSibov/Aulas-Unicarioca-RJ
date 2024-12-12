# Grupo de Segurança para Debian com Docker
resource "aws_security_group" "Debian_Docker_sg" {
 name        = "Debian-Docker-gs"
 description = "Allow SSH, Ping, and Docker"
 vpc_id      = "vpc-0a6b73fda846f0561"

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
 }

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
 }

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
 }

 ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Ping"
 }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

# Instância Debian com Docker
resource "aws_instance" "Debian_Docker" {
 ami                         = "ami-058bd2d568351da34" 
 instance_type               = "t2.micro"
 subnet_id                   = "subnet-0d823ddb2dcf69349" # Altere conforme necessário
 key_name                    = "terraform" # Altere conforme necessário
 associate_public_ip_address = true
 vpc_security_group_ids      = [aws_security_group.Ubuntu_sg.id]

 user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y git docker.io
              systemctl start docker
              systemctl enable docker
              git clone https://github.com/FofuxoSibov/sitebike.git /var/www/html
              docker run -d -p 80:80 -v /var/www/html:/usr/share/nginx/html:ro nginx
              EOF

 tags = {
    Name = "Debian-Docker-Terraform-Marcelo"
 }
}

output "debian_docker_instance_public_ip" {
 description = "IP Publico da Instancia EC2 Debian com Docker"
 value       = aws_instance.Debian_Docker.public_ip
}