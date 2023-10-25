resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${var.aws_lambda_function_name}"
  retention_in_days = 1
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = var.aws_lambda_function_iam_role_name
  policy_arn = aws_iam_policy.function_logging_policy.arn
}

