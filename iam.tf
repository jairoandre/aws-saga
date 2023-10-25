data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = var.aws_lambda_function_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_policy_document.json
}

# SQS Policy Source Events

data "aws_iam_policy_document" "event_source_queues_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = aws_sqs_queue.event_source_queues[*].arn
  }
}

resource "aws_iam_policy" "event_source_queues_iam_policy" {
  policy      = data.aws_iam_policy_document.event_source_queues_policy_document.json
  description = "Grant the Lambda function the required SQS permissions."
}


resource "aws_iam_role_policy_attachment" "event_source_queues_policy_attachment" {
  policy_arn = aws_iam_policy.event_source_queues_iam_policy.arn
  role       = var.aws_lambda_function_iam_role_name
}

# SQS Policy Trigger SAGA queues

data "aws_iam_policy_document" "command_queues_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]
    resources = aws_sqs_queue.command_queues[*].arn
  }
}

resource "aws_iam_policy" "command_queues_iam_policy" {
  policy      = data.aws_iam_policy_document.command_queues_policy_document.json
  description = "Request queues permissions"
}


resource "aws_iam_role_policy_attachment" "command_queues_policy_attachment" {
  policy_arn = aws_iam_policy.command_queues_iam_policy.arn
  role       = var.aws_lambda_function_iam_role_name
}

# Dynamo DB policy

data "aws_iam_policy_document" "dynamodb_access_policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
    ]
    resources = [
      aws_dynamodb_table.bgm_saga_configuration.arn,
      aws_dynamodb_table.bgm_saga_history.arn,
    ]
  }
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  policy = data.aws_iam_policy_document.dynamodb_access_policy.json
  description = "Dynamodb access for lambda saga"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  policy_arn =  aws_iam_policy.lambda_dynamodb_policy.arn
  role = var.aws_lambda_function_iam_role_name
}