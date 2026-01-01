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
- The sandbox environment uses a local backend by default.
- CI runs `terraform init -backend=false` + `terraform validate`.
