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

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions OIDC role (if enabled)."
  value       = try(aws_iam_role.github_actions[0].arn, null)
}

output "github_actions_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider (if enabled)."
  value       = try(aws_iam_openid_connect_provider.github_actions[0].arn, null)
}
