output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value = aws_s3_bucket.lambda_storage_bucket.id
}


output "api_url" {
  description = "The url used to invoke the lambda function"
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}
