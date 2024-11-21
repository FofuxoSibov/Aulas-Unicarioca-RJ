# VPC
resource "aws_vpc" "VPC-CloudPlay" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "VPC-CloudPlay"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "IGW-CloudPlay" {
  vpc_id = aws_vpc.VPC-CloudPlay.id

  tags = {
    Name = "IGW-CloudPlay"
  }
}

# SUBNET Subrede-Pub
resource "aws_subnet" "Subrede-Pub" {
  vpc_id                  = aws_vpc.VPC-CloudPlay.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Subrede-Pub"
  }
}

# SUBNET Subrede-Pri
resource "aws_subnet" "Subrede-Pri" {
  vpc_id            = aws_vpc.VPC-CloudPlay.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subrede-Pri"
  }
}

# ROUTE TABLE Publica
resource "aws_route_table" "Rotas-CloudPlay-Pub" {
  vpc_id = aws_vpc.VPC-CloudPlay.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW-CloudPlay.id
  }

  tags = {
    Name = "Rotas-CloudPlay-Pub"
  }
}

# ROUTE TABLE Privada
resource "aws_route_table" "Rotas-CloudPlay-Pri" {
  vpc_id = aws_vpc.VPC-CloudPlay.id

  tags = {
    Name = "Rotas-CloudPlay-Pri"
  }
}

# SUBNET ASSOCIATION Pub
resource "aws_route_table_association" "Subrede-Pub" {
  subnet_id      = aws_subnet.Subrede-Pub.id
  route_table_id = aws_route_table.Rotas-CloudPlay-Pub.id
}

#SUBNET ASSOCIATION Pri (Desafio NAT Gateway)
#resource "aws_route_table_association" "Subrede-Pri" {
#}

# SECURITY GROUP
resource "aws_security_group" "Grupo-Sec-Linux" {
  name        = "Grupo-Sec-Linux"
  description = "Libera HTTP, SSH e ICMP"
  vpc_id      = aws_vpc.VPC-CloudPlay.id


  ingress {
    description = "TCP/22 from All"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from All"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP/80 from All"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All to All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Grupo-Sec-Linux"
  }
}