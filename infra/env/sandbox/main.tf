locals {
  tags = merge(
    {
      NamePrefix  = var.name_prefix
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "sandbox" {
  name              = "/terraform-sandbox/${var.name_prefix}/${var.environment}"
  retention_in_days = var.log_retention_in_days
  tags              = local.tags
}
