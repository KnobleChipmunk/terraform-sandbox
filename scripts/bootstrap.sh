#!/bin/sh
set -eu

# Minimal bootstrap: ensure scripts are executable (best-effort) and show next steps.

if command -v chmod >/dev/null 2>&1; then
  chmod +x scripts/*.sh 2>/dev/null || true
fi

echo "Bootstrap complete. Next: run 'make verify'."
