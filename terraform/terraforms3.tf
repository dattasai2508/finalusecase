provider "aws" {
  region = "ap-south-1" # Mumbai region
}
 
# Create S3 bucket
resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "datta-bucket-226" # Ensure bucket name is globally unique and uses valid characters
 
  tags = {
    Project     = "StaticWebsiteDeployment"
    Environment = "Production"
  }
}
 
# Website configuration block (replaces deprecated `website` block)
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_website_bucket.id
 
  index_document {
    suffix = "index.html"
  }
}
 
# Allow public access to the bucket
resource "aws_s3_bucket_public_access_block" "static_website_bucket_public_access_block" {
  bucket = aws_s3_bucket.static_website_bucket.id
 
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
 
# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "static_website_bucket_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id
 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_website_bucket.arn}/*"
      }
    ]
  })
 
  depends_on = [aws_s3_bucket_public_access_block.static_website_bucket_public_access_block]
}
 
# Output the website endpoint
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
