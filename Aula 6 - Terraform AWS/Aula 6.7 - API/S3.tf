terraform {
  required_version = ">=1.6.0" # Versão do Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0" # Versão do AWS no Terraform
    }
  }
}


resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "example" {
  bucket       = aws_s3_bucket.example.id
  key          = "meu-arquivo.txt" # Nome do arquivo no bucket
  source       = "caminho/local/do/arquivo/meu-arquivo.txt" # Caminho para o arquivo local
  content_type = "text/plain" # Tipo de conteúdo, ajuste conforme necessário

  depends_on = [aws_s3_bucket.example] # Garantir que o bucket seja criado antes do upload
}