output "url" {
  value = aws_s3_bucket_website_configuration.bucket-web.website_endpoint
}