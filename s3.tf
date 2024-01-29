resource "random_pet" "name" {
  prefix = "golang-lambda-api-gateway"
  length = 4
}

resource "aws_s3_bucket" "lambda_storage_bucket" {
  bucket = bits_bucket_name.name.id
}

resource "aws_s3_bucket_ownership_controls" "lambda_storage_bucket" {
  bucket = aws_s3_bucket.lambda_storage_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_storage_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_storage_bucket]

  bucket = aws_s3_bucket.lambda_storage_bucket.id
  acl    = "private"
}
