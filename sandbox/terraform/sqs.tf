resource "aws_sqs_queue" "sandbox_dead_letter" {
  name                      = "aft-sandbox-dead-letter"
  message_retention_seconds = 1209600
  kms_master_key_id         = "alias/aws/sqs"

  tags = {
    Name    = "aft-sandbox-dead-letter"
    Purpose = "Failed sandbox messages"
  }
}

resource "aws_sqs_queue" "sandbox" {
  name                       = "aft-sandbox"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 20
  kms_master_key_id          = "alias/aws/sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sandbox_dead_letter.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name    = "aft-sandbox"
    Purpose = "Sandbox application messages"
  }
}

output "sandbox_queue_url" {
  description = "URL of the sandbox SQS queue."
  value       = aws_sqs_queue.sandbox.id
}

output "sandbox_queue_arn" {
  description = "ARN of the sandbox SQS queue."
  value       = aws_sqs_queue.sandbox.arn
}
