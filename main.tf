provider "aws" {
  region  = local.aws_region
}


terraform {
  backend "s3" {

  }
}


variable "env_name" {
  description = "The environment to deploy to"
  type        = string
  default     = "dev"
}


locals {
  app_name = "ex-form-app"
  aws_region = "ap-southeast-2"
}

resource "aws_s3_bucket" "app" {
  bucket        = "${var.env_name}-${local.app_name}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.app.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "null_resource" "upload_app" {
  triggers = {
    content_hash = sha1(join("", [for f in fileset("./dist", "**"): filesha1("./dist/${f}")]))
  }

  provisioner "local-exec" {
    command = "aws s3 sync ./dist/ s3://${aws_s3_bucket.app.bucket}/"
  }
}


resource "aws_cloudfront_origin_access_control" "app" {
  name                              = "${var.env_name}-${local.app_name}-oac"
  description                       = "OAC for ${var.env_name}-${local.app_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "app" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.app.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.app.id
    origin_access_control_id = aws_cloudfront_origin_access_control.app.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.app.id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Custom error response for SPA
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket_policy" "app" {
  bucket = aws_s3_bucket.app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.app.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.app.arn
          }
        }
      }
    ]
  })
}

resource "null_resource" "build_app" {
  triggers = {
    content_hash = sha1(join("", [for f in fileset("./src", "**"): filesha1("./src/${f}")]))
  }

  provisioner "local-exec" {
    command = "npm run build"
  }
}


resource "null_resource" "invalidate_cache" {
  depends_on = [aws_cloudfront_distribution.app, null_resource.build_app]
  triggers = {
    content_hash = sha1(join("", [for f in fileset("./dist", "**"): filesha1("./dist/${f}")]))
  }
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.app.id} --paths '/*' --profile=terraform"
  }

}

output "s3_bucket_name" {
  value = aws_s3_bucket.app.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.app.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.app.id
}