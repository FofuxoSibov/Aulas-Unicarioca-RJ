resource "aws_s3_bucket" "bucket" {
  bucket = "meu-bucket-fernando-134"
  #acl    = "public-read"
  tags = {
    Name = "meu-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket-controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_public_access_block" "bucket-block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "bucket-version" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
  resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
  ]
actions = ["S3:GetObject", "s3:PutBucketAcl"]
principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
  depends_on = [aws_s3_bucket_public_access_block.bucket-block]
}


resource "aws_s3_bucket_website_configuration" "bucket-web" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

locals {
  sitebike_files = fileset("./sitebike", "**/*.*")
}

resource "aws_s3_object" "upload_object" {
  for_each      = { for file in local.sitebike_files : file => file }
  bucket        = aws_s3_bucket.bucket.id
  key           = each.value
  source        = "./sitebike/${each.value}"
  etag          = filemd5("./sitebike/${each.value}")
  content_type  = "text/html"
  #acl             = "public-read"
}
