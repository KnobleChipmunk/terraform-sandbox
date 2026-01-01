output "aws_region" {
  description = "AWS region configured for this environment."
  value       = var.aws_region
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group created for the sandbox."
  value       = aws_cloudwatch_log_group.sandbox.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group created for the sandbox."
  value       = aws_cloudwatch_log_group.sandbox.arn
}
