resource "aws_dynamodb_table" "bgm_saga_configuration" {
  name         = "bgm_saga_configuration"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "saga_id"
  range_key    = "step_order"
  attribute {
    name = "saga_id"
    type = "S"
  }
  attribute {
    name = "step_order"
    type = "N"
  }
}


resource "aws_dynamodb_table" "bgm_saga_history" {
  name         = "bgm_saga_history"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "transaction_id"
  range_key    = "correlation_id"
  attribute {
    name = "transaction_id"
    type = "S"
  }
  attribute {
    name = "correlation_id"
    type = "S"
  }
}


