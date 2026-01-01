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

## Applying to AWS
Terraform can run without long-lived keys. The runbook describes two common approaches:
- **Local apply via AWS SSO** (best UX when permission sets/AWS account assignments are available)
- **Console apply via CloudShell** (works even for private repos by uploading a zip)

