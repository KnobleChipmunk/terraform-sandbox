# terraform-sandbox

Beginner-friendly AWS Terraform sandbox (single-account) with strict guardrails:
- Region: **us-east-2**
- Environment: **sandbox**
- Local auth: **AWS SSO** (no long-lived keys)
- CI later: GitHub Actions **OIDC** (no secrets)

## Start here
- Runbook: [agent-output/README_RUNBOOK.md](agent-output/README_RUNBOOK.md)
- Cost guardrails: [agent-output/COST_GUARDRAILS.md](agent-output/COST_GUARDRAILS.md)

## Day 0 → Day 2
- Day 0: `make bootstrap`, `make verify`, then `aws configure sso --profile sandbox` + login
- Day 1: `make tf-fmt`, `make tf-validate`, `make tf-plan`
- Day 2: budgets/alerts first; plug in GitHub Actions OIDC later
