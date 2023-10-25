variable "event_source_queue_names" {
  description = "List of names of queues that triggers the lambda."
  type        = list(string)
  default = [
    "gbm-create-saga_queue",
    "gbm-start-saga_queue",
    "gbm-response-saga_queue",
  ]
}

# Response saga queue event:
# { transactionId: uuid, success: boolean }
#
#

variable "command_queue_names" {
  description = "List of names of command queues."
  type        = list(string)
  default = [
    "gbm-command-accounts",
    "gbm-command-auth",
    "gbm-command-person"
  ]
}

locals {
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-queueconfig
  # To allow your function time to process each batch of records, set the source queue's visibility timeout to at least 6 times the timeout that you configure on your function. The extra time allows for Lambda to retry if your function execution is throttled while your function is processing a previous batch.
  visibility_timeout_seconds = coalesce(
    # Use whatever the user provided if it is not null
    var.visibility_timeout_seconds,
    # But if it is - calculate our own value
    30 * 6,
  )
}

# Request queues

resource "aws_sqs_queue" "command_dlqs" {
  count = length(var.command_queue_names)
  name  = "${var.command_queue_names[count.index]}_dlq"
}


resource "aws_sqs_queue" "command_queues" {
  count                      = length(var.command_queue_names)
  name                       = "${var.command_queue_names[count.index]}_queue"
  visibility_timeout_seconds = local.visibility_timeout_seconds
  delay_seconds              = var.delay_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.command_dlqs[count.index].arn
    maxReceiveCount     = var.deadletter_max_receive_count
  })

  depends_on = [aws_sqs_queue.command_dlqs]
}

# Event source queues (feedback, creation and start SAGAS)

resource "aws_sqs_queue" "event_source_dlqs" {
  count = length(var.event_source_queue_names)
  name  = "${var.event_source_queue_names[count.index]}_dlq"
}

resource "aws_sqs_queue" "event_source_queues" {
  count                      = length(var.event_source_queue_names)
  name                       = var.event_source_queue_names[count.index]
  visibility_timeout_seconds = local.visibility_timeout_seconds
  delay_seconds              = var.delay_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.event_source_dlqs[count.index].arn
    maxReceiveCount     = var.deadletter_max_receive_count
  })

  depends_on = [aws_sqs_queue.event_source_dlqs]

}
