resource "aws_instance" "Linux" {
  ami                    = "ami-0d7a109bf30624c99"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-0fac1f1baf7c67c24"
  key_name = "LinuxServerKeys"
  associate_public_ip_address = "true"

  tags = {
    Name = "Linux-Terraform-01"
  }
}

output "instance_public_ip" {
  description = "IP Publico da Instancia EC2"
  value       = aws_instance.Linux.public_ip
}