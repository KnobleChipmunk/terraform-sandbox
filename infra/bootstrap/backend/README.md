# Remote State Backend (Bootstrap)

This Terraform root creates the **S3 bucket + DynamoDB table** used for remote state and state locking.

Why this exists:
- The sandbox environment can't create its own backend and use it at the same time (chicken/egg).
- This is a one-time (or rarely-changed) bootstrap step.

## Safe workflow (recommended)

1) Plan:
- `terraform -chdir=infra/bootstrap/backend init`
- `terraform -chdir=infra/bootstrap/backend plan`

2) Apply (creates S3 + DynamoDB):
- `terraform -chdir=infra/bootstrap/backend apply`

3) Use the outputs to configure remote state for the sandbox env.

Costs (roughly):
- S3: pennies/month for small state files
- DynamoDB on-demand: near-zero unless locking frequently
