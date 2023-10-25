provider "aws" {
  region = var.aws_region
}

provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "app.py"
  output_path = "app.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.aws_lambda_function_name
  role             = aws_iam_role.lambda_iam_role.arn
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  environment {
    variables = {
      CONFIG_SAGA_QUEUE_ARN = aws_sqs_queue.event_source_queues[0].arn
    }
  }
  depends_on       = [aws_iam_role.lambda_iam_role]
}
