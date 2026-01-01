#!/bin/sh
set -eu

fail=0

require_file() {
  if [ ! -f "$1" ]; then
    echo "Missing required file: $1" >&2
    fail=1
  fi
}

require_dir() {
  if [ ! -d "$1" ]; then
    echo "Missing required dir:  $1" >&2
    fail=1
  fi
}

require_file README.md
require_file Makefile
require_file .editorconfig
require_file .gitignore
require_dir docs
require_dir scripts
require_dir src
require_dir tests
require_dir infra

# Validate shell scripts parse
for f in scripts/*.sh; do
  [ -f "$f" ] || continue
  sh -n "$f" || fail=1

done

# Run shellcheck if present
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck scripts/*.sh || fail=1
fi

# Terraform checks (optional)
if command -v terraform >/dev/null 2>&1; then
  # Only check formatting for tracked Terraform files.
  # This avoids local ignored files (like *.auto.tfvars) breaking `make verify`.
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    tracked_tf_files=$(git ls-files infra | grep -E '\.(tf|tfvars|tf\.json|tfvars\.json)$' || true)
    if [ -n "$tracked_tf_files" ]; then
      terraform fmt -check $tracked_tf_files || fail=1
    else
      terraform fmt -check -recursive infra || fail=1
    fi
  else
    terraform fmt -check -recursive infra || fail=1
  fi
  (cd infra/env/sandbox && terraform init -backend=false) || fail=1
  (cd infra/env/sandbox && terraform validate) || fail=1
fi

# Python checks (optional)
if command -v python >/dev/null 2>&1; then
  python -m compileall -q src || fail=1
  if python -m ruff --version >/dev/null 2>&1; then
    python -m ruff check . || fail=1
  fi
  if python -m pytest --version >/dev/null 2>&1; then
    PYTHONPATH=src python -m pytest -q || fail=1
  fi
fi

if [ "$fail" -ne 0 ]; then
  echo "Verify failed." >&2
  exit 1
fi

echo "Verify OK."
