variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name (e.g., sandbox)."
  type        = string
  default     = "sandbox"
}

variable "name_prefix" {
  description = "Prefix for resource naming."
  type        = string
  default     = "sandbox"
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "enable_budgets" {
  description = "Whether to manage AWS Budgets via Terraform. Default false to avoid surprising account-level changes."
  type        = bool
  default     = false
}

variable "monthly_budget_soft_limit_usd" {
  description = "Monthly cost budget soft limit in USD."
  type        = number
  default     = 25
}

variable "monthly_budget_hard_limit_usd" {
  description = "Monthly cost budget hard limit in USD."
  type        = number
  default     = 50
}

variable "enable_budget_notifications" {
  description = "Whether budgets should send email notifications."
  type        = bool
  default     = false
}

variable "budget_notification_emails" {
  description = "Email addresses to notify for budget thresholds. Supply via ignored tfvars or TF_VAR_ env var. If empty, notifications are skipped."
  type        = list(string)
  default     = []

  sensitive = true


}

