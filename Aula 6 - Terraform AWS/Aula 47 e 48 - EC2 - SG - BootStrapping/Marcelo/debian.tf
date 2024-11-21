# Grupo de Segurança para Debian
resource "aws_security_group" "Debian_sg" {
 name        = "Debian-gs"
 description = "Allow SSH and Ping"
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

resource "aws_instance" "Debian" {
 ami                         = "ami-058bd2d568351da34" # Substitua pelo ID da AMI do Debian
 instance_type               = "t2.micro"
 subnet_id                   = "subnet-0d823ddb2dcf69349" # Altere conforme necessário
 key_name                    = "terraform" # Altere conforme necessário
 associate_public_ip_address = true
 vpc_security_group_ids      = [aws_security_group.Debian_sg.id] # Certifique-se de usar o grupo de segurança correto

 user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y git nginx
              systemctl start nginx
              systemctl enable nginx
              git clone https://github.com/FofuxoSibov/sitebike.git /var/www/sitebike
              echo "server {
                      listen 80;
                      server_name _;
                      root /var/www/sitebike;
                      index index.html index.htm;
                      location / {
                          try_files \$uri \$uri/ =404;
                      }
                      location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
                          expires 30d;
                      }
                 }" > /etc/nginx/sites-available/sitebike
              ln -s /etc/nginx/sites-available/sitebike /etc/nginx/sites-enabled/
              rm /etc/nginx/sites-enabled/default
              systemctl restart nginx
              EOF

 tags = {
    Name = "Debian-Terraform-Marcelo"
 }
}

output "debian_instance_public_ip" {
 description = "IP Publico da Instancia EC2 Debian"
 value       = aws_instance.Debian.public_ip
}