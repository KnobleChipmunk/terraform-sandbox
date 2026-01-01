variable "aws_region" {
  description = "AWS region to deploy the remote state backend into."
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix used for naming backend resources. Keep it short and lowercase."
  type        = string
  default     = "terraform-sandbox"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must be lowercase and may contain only letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment tag value (e.g., sandbox)."
  type        = string
  default     = "sandbox"
}

variable "tags" {
  description = "Extra tags to apply to all resources."
  type        = map(string)
  default     = {}
}
