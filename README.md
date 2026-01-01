# terraform-sandbox

Beginner-friendly AWS Terraform sandbox for learning infrastructure-as-code with strong safety defaults.

**Defaults**
- AWS region: **us-east-2**
- Environment name: **sandbox**
- No long-lived secrets (prefer SSO / short-lived credentials)

## Start here
- Terraform layout: [infra/README.md](infra/README.md)

## Day 0 → Day 2
- Day 0: `make bootstrap`, `make verify`
- Day 1: `make tf-fmt`, `make tf-validate`, `make tf-plan`
- Day 2: add budgets/alerts + remote state, then expand infra (OIDC apply later)

## What’s in this repo
- A sandbox Terraform environment root at `infra/env/sandbox/`
- Make targets to standardize `fmt` / `validate` / `plan`
- GitHub Actions CI for safe checks (fmt/validate/lint/tests) — no AWS credentials required

## GitHub Actions: Terraform Apply (OIDC)
This repo includes a manual GitHub Actions workflow that can run `terraform apply` in AWS **without long‑lived AWS keys**, using GitHub’s OIDC token to assume an IAM role.

Where: `.github/workflows/terraform_apply.yml`

Prereqs (one-time):
- Remote state is configured (S3 + DynamoDB). See `infra/bootstrap/backend/`.
- The OIDC IAM resources exist in AWS (provider + role + policy) from `infra/env/sandbox/`.
- GitHub Environment `sandbox` is configured with variables:
	- `AWS_ROLE_ARN` (role to assume)
	- `TF_BACKEND_BUCKET` (S3 state bucket)
	- `TF_BACKEND_DDB_TABLE` (DynamoDB lock table)
	- Optional: `BUDGET_NOTIFICATION_EMAILS` as a JSON list string, e.g. `["you@example.com"]`.

Notes:
- GitHub Environment variables are **not publicly readable**, but anyone with write/admin access (or permission to edit workflows) could read/exfiltrate them. Avoid putting secrets here.
- The workflow explicitly sets `TF_VAR_enable_github_actions_oidc=true` and `TF_VAR_enable_budgets=true` to prevent `count`-based resources from being planned for destruction due to safety defaults.
- `budget_notification_emails` is marked `sensitive` in Terraform to reduce email leakage in logs; still avoid echoing env vars in workflow steps.

## Applying to AWS
Terraform can run without long-lived keys. The runbook describes two common approaches:
- **Local apply via AWS SSO** (best UX when permission sets/AWS account assignments are available)
- **Console apply via CloudShell** (works even for private repos by uploading a zip)

A third option is the manual GitHub Actions OIDC apply described above.

