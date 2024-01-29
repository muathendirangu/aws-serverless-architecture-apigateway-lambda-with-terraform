resource "aws_iam_role" "bits" {
  name = "bits-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "bits" {
  name        = "bits-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
    },{
      Effect = "Allow"
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ]
      Resource = ["*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bits" {
  policy_arn = aws_iam_policy.bits.arn
  role = aws_iam_role.bits.name
}


resource "aws_lambda_function" "bits" {
  s3_bucket = aws_s3_bucket.lambda_storage_bucket.id
  s3_key    = aws_s3_object.lambda_zip.key
  function_name    = local.app_id
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  handler          = "app"
  role             = aws_iam_role.bits.arn
  runtime          =var.app_runtime
  vpc_config {
    subnet_ids = [aws_subnet.bits.id]
    security_group_ids = [aws_security_group.bits.id]
  }
}
