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
