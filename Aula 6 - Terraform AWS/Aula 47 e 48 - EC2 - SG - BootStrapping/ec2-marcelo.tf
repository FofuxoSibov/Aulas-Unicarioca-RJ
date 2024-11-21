resource "aws_security_group" "Linux_sg" {
 name        = "Linux-gs"
 description = "Allow SSH and Ping"
 vpc_id = "vpc-0a6b73fda846f0561"

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

resource "aws_instance" "Linux" {
 ami                         = "ami-0d7a109bf30624c99" # Substitua pelo ID da AMI do Windows
 instance_type               = "t2.micro"
 subnet_id                   = "subnet-0d823ddb2dcf69349" # Altere conforme necessário
 key_name                    = "terraform"# Altere conforme necessário
 associate_public_ip_address = true
 vpc_security_group_ids      = [aws_security_group.Linux_sg.id]

user_data = <<-EOF
              #!/bin/bash
              echo '${file("C:/Users/46683590842/Documents/Projeto-terraform/Scripts/script.sh")}' > /home/ec2-user/script.sh
              chmod +x /home/ec2-user/script.sh
              /home/ec2-user/script.sh
              EOF

 tags = {
    Name = "Linux-Terraform-Marcelo"
 }
}

output "instance_public_ip" {
 description = "IP Publico da Instancia EC2 linux"
 value       = aws_instance.Linux.public_ip
}
