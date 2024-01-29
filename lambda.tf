resource "bits_iam_lambda_role" "bits" {
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

resource "bits_iam_lambda_policy" "bits" {
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

resource "bits_iam_lambda_role_policy_attachment" "bits" {
  policy_arn = bits_iam_lambda_policy.bits.arn
  role = bits_iam_lambda_role.bits.name
}


resource "bits_lambda_function" "bits" {
  function_name    = local.app_id
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  handler          = "app"
  role             = bits_iam_lambda_role.bits.arn
  runtime          =var.app_runtime
  vpc_config {
    subnet_ids = [bits_subnet.bits.id]
    security_group_ids = [bits_sg.bits.id]
  }
}
