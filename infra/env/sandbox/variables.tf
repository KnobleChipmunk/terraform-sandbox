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
