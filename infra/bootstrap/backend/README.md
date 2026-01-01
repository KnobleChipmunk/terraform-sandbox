# Remote State Backend (Bootstrap)

This Terraform root creates the **S3 bucket + DynamoDB table** used for remote state and state locking.

Why this exists:
- The sandbox environment can't create its own backend and use it at the same time (chicken/egg).
- This is a one-time (or rarely-changed) bootstrap step.

## Safe workflow (recommended)

## CloudShell disk space note
AWS CloudShell has limited home directory space, and the AWS provider binary is large.
If `terraform init` fails with `no space left on device`, try:

- Remove Terraform working dirs (safe):
  - `rm -rf infra/**/.terraform`

- Use `/tmp` for Terraform’s working dir + provider cache:
  - `export TF_DATA_DIR=/tmp/tf-data`
  - `export TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache`
  - Re-run `terraform init` / `plan`

You can `unset TF_DATA_DIR TF_PLUGIN_CACHE_DIR` afterward.


1) Plan:
- `terraform -chdir=infra/bootstrap/backend init`
- `terraform -chdir=infra/bootstrap/backend plan`

2) Apply (creates S3 + DynamoDB):
- `terraform -chdir=infra/bootstrap/backend apply`

3) Use the outputs to configure remote state for the sandbox env.

Costs (roughly):
- S3: pennies/month for small state files
- DynamoDB on-demand: near-zero unless locking frequently


If your home directory volume is full (often shows as `/dev/loop0` at 100%), the most reliable fix is to run from a larger mount (CloudShell usually has ~25GB at `/aws/mde/mde`):

- `cd /aws/mde/mde`
- `cp -a ~/terraform-sandbox .`  (or re-clone with `git clone ...`)
- `rm -rf ~/terraform-sandbox`  (frees the small home volume)
- `cd /aws/mde/mde/terraform-sandbox`
