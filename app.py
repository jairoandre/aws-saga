import boto3
import json
import os

CONFIG_SAGA_QUEUE_ARN = os.getenv("CONFIG_SAGA_QUEUE_ARN")

#{
# "Records": [
#     {
#         "messageId": "059f36b4-87a3-44ab-83d2-661975830a7d",
#         "receiptHandle": "AQEBwJnKyrHigUMZj6rYigCgxlaS3SLy0a...",
#         "body": "Test message.",
#         "attributes": {
#             "ApproximateReceiveCount": "1",
#             "SentTimestamp": "1545082649183",
#             "SenderId": "AIDAIENQZJOLO23YVJ4VO",
#             "ApproximateFirstReceiveTimestamp": "1545082649185"
#         },
#         "messageAttributes": {},
#         "md5OfBody": "e4e68fb7bd0e697a0ae8f1bb342846b3",
#         "eventSource": "aws:sqs",
#         "eventSourceARN": "arn:aws:sqs:us-east-2:123456789012:my-queue",
#         "awsRegion": "us-east-2"
#     }
#}
def lambda_handler(event, context):
  records = event['Records']
  response = {}
  for record in records:
    if record['eventSourceARN'] == CONFIG_SAGA_QUEUE_ARN:
      dynamodb = boto3.resource('dynamodb')
      table_name = 'bgm_saga_configuration'
      table = dynamodb.Table(table_name)
      body = json.loads(record['body'])
      saga_id = body['saga_id']
      try:
        for step in body['steps']:
          item = {
            'saga_id': saga_id,
            'step_order': step['order'],
            'command_queue': step['command_queue'],
            'rollback_queue': step['rollback_queue'],
          }
          table.put_item(Item=item)
        response = {
          'statusCode': 200,
          'body': json.dumps('Saga added to the config table')
        }
      except Exception as e:
        response = {
          'statusCode': 500,
          'body': json.dumps('Error adding saga to the config table')
        }
  return response