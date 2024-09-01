provider "aws" {
  region = "us-east-2"  # Change to your preferred region
}

# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket"{
  bucket = "my-unique-bucket-name-blessy"  # Change to your preferred bucket name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "terraform-lambda-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Archive a single file.

data "archive_file" "lambda_handler" {
  type        = "zip"
  source_file = "${path.module}/lambda_handler.py"
  output_path = "${path.module}/lambda_handler.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "lambda_handler.zip"
  function_name    = "myTerraformLambdaFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.8"
  timeout          = 60
  depends_on       = [aws_iam_role.lambda_execution_role, data.archive_file.lambda_handler]
}