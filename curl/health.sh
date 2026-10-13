#!/usr/bin/env bash
# Health check — the only endpoint that needs no API key.
# Usage: ./health.sh
set -euo pipefail

BASE_URL="${HIVORA_BASE_URL:-https://sandbox.hivoralabs.com/api/v1}"

curl -sS -w '\nHTTP %{http_code}\n' \
  "$BASE_URL/health"
