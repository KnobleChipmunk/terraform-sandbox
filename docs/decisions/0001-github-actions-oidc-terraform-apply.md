# 0001 - GitHub Actions OIDC for Terraform Apply

Status: accepted

Date: 2026-01-01

## Context
We want a beginner-friendly AWS Terraform sandbox with strong safety defaults:
- Avoid long-lived AWS access keys
- Keep cost controls enabled (budgets)
- Keep local developer UX simple (SSO/CloudShell)
- Allow a CI/CD path for `terraform apply` without secrets

GitHub Actions can authenticate to AWS using OIDC (`sts:AssumeRoleWithWebIdentity`) instead of stored AWS keys.

## Decision
- Use a manual GitHub Actions workflow (`workflow_dispatch`) to run `terraform apply` for the sandbox environment.
- Configure AWS auth in the workflow with `aws-actions/configure-aws-credentials@v4` and `id-token: write`.
- Restrict the role trust policy `sub` to the repo and **GitHub Environment** subject:
  - `repo:<owner>/<repo>:environment:sandbox`
  - (Optionally also allow the `ref:` subject when jobs do not use an environment.)
- Store backend config inputs and optional budget notification emails as **GitHub Environment variables** (not in git).
- Keep Terraform safety defaults (`enable_budgets`, `enable_github_actions_oidc`) as `false` in code to avoid surprising account-level changes, but set the required `TF_VAR_` values explicitly in the workflow.
- Mark `budget_notification_emails` as `sensitive` in Terraform to reduce accidental exposure in CI logs.

## Consequences
- Pros:
  - No long-lived AWS keys in GitHub
  - Manual apply reduces blast radius while learning
  - Remote state enables collaboration and CI

- Cons / cautions:
  - GitHub Environment variables are not public, but users with write/admin access (or ability to modify workflows) can read/exfiltrate them.
  - Terraform must have sufficient IAM read permissions for refresh (e.g., tag listing actions and IAM `Get*` calls).
  - If the workflow stops passing `TF_VAR_enable_*` flags, `count`-based resources may be planned for destruction.
