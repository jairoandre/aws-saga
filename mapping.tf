resource "aws_lambda_event_source_mapping" "event_source_queues_mapping" {
  count            = length(aws_sqs_queue.event_source_queues)
  event_source_arn = aws_sqs_queue.event_source_queues[count.index].arn
  function_name    = var.aws_lambda_function_name

  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds

  enabled = var.enabled

  depends_on = [
    # Only create the event_source_mapping when IAM permissions are already attached
    aws_iam_role_policy_attachment.event_source_queues_policy_attachment,
    aws_iam_role_policy_attachment.command_queues_policy_attachment
  ]
}
