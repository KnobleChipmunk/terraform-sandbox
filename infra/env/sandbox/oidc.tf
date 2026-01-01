# GitHub Actions OIDC (optional)
#
# This creates an IAM role that GitHub Actions can assume without long-lived AWS keys.
# It is disabled by default; set enable_github_actions_oidc=true to enable.

data "aws_caller_identity" "current" {}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  tfstate_bucket_name = "${var.backend_name_prefix}-tfstate-${data.aws_caller_identity.current.account_id}"
  tflock_table_name   = "${var.backend_name_prefix}-tflock-${data.aws_caller_identity.current.account_id}"
}

locals {
  github_actions_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  github_actions_role_arn          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.github_actions_role_name}"
  github_actions_policy_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.github_actions_role_name}-policy"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enable_github_actions_oidc ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions" {
  count = var.enable_github_actions_oidc ? 1 : 0

  name = var.github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions[0].arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_repo_full_name}:ref:${var.github_ref}",
              "repo:${var.github_repo_full_name}:environment:${var.github_environment}",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_terraform" {
  count = var.enable_github_actions_oidc ? 1 : 0

  name        = "${var.github_actions_role_name}-policy"
  description = "Permissions for Terraform runs in GitHub Actions (sandbox)."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Remote state access
      {
        Sid    = "TfStateS3"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.tfstate_bucket_name}"
        ]
      },
      {
        Sid    = "TfStateS3Objects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${local.tfstate_bucket_name}/*"
        ]
      },
      {
        Sid    = "TfStateLockDynamo"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${local.tflock_table_name}"
        ]
      },

      # CloudWatch Log Group resource management
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:UntagResource"
        ]
        Resource = "*"
      },

      # Budgets are account-level and typically require wildcard resources.
      {
        Sid    = "Budgets"
        Effect = "Allow"
        Action = [
          "budgets:CreateBudget",
          "budgets:DeleteBudget",
          "budgets:Describe*",
          "budgets:ListTagsForResource",
          "budgets:ModifyBudget",
          "budgets:UpdateBudget",
          "budgets:ViewBudget",
          "budgets:CreateNotification",
          "budgets:DeleteNotification",
          "budgets:CreateSubscriber",
          "budgets:DeleteSubscriber",
          "budgets:UpdateNotification",
          "budgets:UpdateSubscriber"
        ]
        Resource = "*"
      },

      # IAM permissions required for Terraform to read/update the OIDC provider,
      # role, and policy that enable GitHub Actions.
      {
        Sid    = "IamReadForTerraform"
        Effect = "Allow"
        Action = [
          "iam:GetOpenIDConnectProvider",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions"
        ]
        Resource = [
          local.github_actions_oidc_provider_arn,
          local.github_actions_policy_arn
        ]
      },
      {
        Sid    = "IamPolicyVersionManagement"
        Effect = "Allow"
        Action = [
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion"
        ]
        Resource = [
          local.github_actions_policy_arn
        ]
      },
      {
        Sid    = "IamRoleReadWrite"
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:UpdateAssumeRolePolicy"
        ]
        Resource = [
          local.github_actions_role_arn
        ]
      },
      {
        Sid    = "IamOidcProviderWrite"
        Effect = "Allow"
        Action = [
          "iam:UpdateOpenIDConnectProviderThumbprint"
        ]
        Resource = [
          local.github_actions_oidc_provider_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  count = var.enable_github_actions_oidc ? 1 : 0

  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.github_actions_terraform[0].arn
}
