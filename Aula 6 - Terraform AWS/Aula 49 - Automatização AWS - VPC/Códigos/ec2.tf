# EC2 INSTANCE Pub e Pri
data "template_file" "user_data" {
  template = file("./scripts/user_data.sh")
}

resource "aws_instance" "Linux-Pub" {
  ami                    = "ami-005f9685cb30f234b"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Subrede-Pub.id
  key_name = "LinuxServerKeys"
  vpc_security_group_ids = [aws_security_group.Grupo-Sec-Linux.id]
  user_data              = base64encode(data.template_file.user_data.rendered)

  tags = {
    Name = "Linux-Pub"
  }
}

resource "aws_instance" "Linux-Pri" {
  ami                    = "ami-005f9685cb30f234b"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Subrede-Pri.id
  key_name = "LinuxServerKeys"
  vpc_security_group_ids = [aws_security_group.Grupo-Sec-Linux.id]
  user_data              = base64encode(data.template_file.user_data.rendered)

  tags = {
    Name = "Linux-Pri"
  }
}

output "instance_public_ip" {
  description = "IP Publico da Instancia EC2"
  value       = aws_instance.Linux-Pub.public_ip
}