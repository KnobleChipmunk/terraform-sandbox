# Infrastructure (Terraform)

This folder contains Terraform configuration for AWS.

## Layout
- `infra/env/` – environment roots (e.g., `sandbox`)
- `infra/modules/` – reusable modules (optional; add as needed)

## Quickstart
From the repo root:
- Format: `make tf-fmt`
- Validate: `make tf-validate`

Notes:
- The sandbox environment uses local state unless you configure remote state (recommended).
- CI runs `terraform init -backend=false` + `terraform validate`.

## Remote state
See the bootstrap root under `infra/bootstrap/backend/`.

### Bootstrapping remote state
The bootstrap root creates:
- An S3 bucket for Terraform state (versioned, encrypted, public access blocked)
- A DynamoDB table for state locking

After bootstrapping, the sandbox environment (`infra/env/sandbox/`) can be initialized with S3 backend config.

## Apply options

### 1) CloudShell / local (SSO)
Run Terraform from CloudShell or a local machine authenticated via AWS SSO.

### 2) GitHub Actions (OIDC)
There is a manual workflow that runs `terraform apply` using GitHub OIDC (no stored AWS keys):
- Workflow: `.github/workflows/terraform_apply.yml`
- Environment: `sandbox`

GitHub Environment variables required:
- `AWS_ROLE_ARN`
- `TF_BACKEND_BUCKET`
- `TF_BACKEND_DDB_TABLE`

Optional budgets notifications:
- `BUDGET_NOTIFICATION_EMAILS` as a JSON list string (Terraform parses `TF_VAR_` values as HCL/JSON), e.g. `["you@example.com"]`.

Terraform safety defaults:
- `enable_budgets` and `enable_github_actions_oidc` default to `false` in code to avoid surprise account-level changes.
- The workflow sets `TF_VAR_enable_budgets=true` and `TF_VAR_enable_github_actions_oidc=true` explicitly so CI does not plan to destroy existing resources.
