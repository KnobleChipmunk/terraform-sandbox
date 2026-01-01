# AWS Budgets are account-level (not region-level). This configuration creates two
# monthly COST budgets and (optionally) sends alerts to email subscribers.
#
# To avoid committing emails in a public repo, set:
#   enable_budget_notifications = true
#   budget_notification_emails  = ["<YOUR_EMAIL>"]
# in an ignored tfvars file (see README_RUNBOOK).

resource "aws_budgets_budget" "monthly_soft" {
  count        = var.enable_budgets ? 1 : 0
  name         = "${var.name_prefix}-${var.environment}-monthly-cost-soft"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_soft_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Approximate "net" behavior by excluding credits/refunds/discounts.
  # (Exact definitions vary; verify in the Budgets console after creation.)
  cost_types {
    include_credit   = false
    include_refund   = false
    include_discount = false
  }

  dynamic "notification" {
    for_each = var.enable_budget_notifications ? [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 50
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      },
    ] : []

    content {
      comparison_operator = notification.value.comparison_operator
      threshold           = notification.value.threshold
      threshold_type      = notification.value.threshold_type
      notification_type   = notification.value.notification_type

      subscriber_email_addresses = var.budget_notification_emails
    }
  }
}

resource "aws_budgets_budget" "monthly_hard" {
  count        = var.enable_budgets ? 1 : 0
  name         = "${var.name_prefix}-${var.environment}-monthly-cost-hard"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_hard_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_types {
    include_credit   = false
    include_refund   = false
    include_discount = false
  }

  dynamic "notification" {
    for_each = var.enable_budget_notifications ? [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 80
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
      },
      {
        comparison_operator = "GREATER_THAN"
        threshold           = 100
        threshold_type      = "PERCENTAGE"
        notification_type   = "FORECASTED"
      },
    ] : []

    content {
      comparison_operator = notification.value.comparison_operator
      threshold           = notification.value.threshold
      threshold_type      = notification.value.threshold_type
      notification_type   = notification.value.notification_type

      subscriber_email_addresses = var.budget_notification_emails
    }
  }
}
