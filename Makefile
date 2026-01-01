.PHONY: help verify bootstrap tf-fmt tf-init tf-validate tf-plan py-lint py-test

help:
	@echo "Targets:"
	@echo "  make verify       Run repo checks"
	@echo "  make bootstrap    Initialize local dev setup"
	@echo "  make tf-fmt       Format Terraform"
	@echo "  make tf-init      Terraform init (backend disabled)"
	@echo "  make tf-validate  Terraform validate (backend disabled)"
	@echo "  make tf-plan      Terraform plan"
	@echo "  make py-lint      Lint Python (ruff)"
	@echo "  make py-test      Run Python tests (pytest)"

verify:
	@sh scripts/verify.sh

bootstrap:
	@sh scripts/bootstrap.sh

tf-fmt:
	@terraform fmt -recursive infra

tf-init:
	@terraform -chdir=infra/env/sandbox init -backend=false

tf-validate:
	@terraform -chdir=infra/env/sandbox init -backend=false
	@terraform -chdir=infra/env/sandbox validate

tf-plan:
	@terraform -chdir=infra/env/sandbox init -backend=false
	@terraform -chdir=infra/env/sandbox plan

py-lint:
	@python -m ruff check .

py-test:
	@PYTHONPATH=src python -m pytest

.PHONY: tf-backend-init tf-backend-plan tf-backend-apply tf-init-remote tf-plan-remote

tf-backend-init:
	@terraform -chdir=infra/bootstrap/backend init

tf-backend-plan:
	@terraform -chdir=infra/bootstrap/backend init
	@terraform -chdir=infra/bootstrap/backend plan

tf-backend-apply:
	@terraform -chdir=infra/bootstrap/backend init
	@terraform -chdir=infra/bootstrap/backend apply

# Requires infra/env/sandbox/backend.hcl (ignored by git)

tf-init-remote:
	@terraform -chdir=infra/env/sandbox init -backend-config=backend.hcl

tf-plan-remote:
	@terraform -chdir=infra/env/sandbox init -backend-config=backend.hcl
	@terraform -chdir=infra/env/sandbox plan
