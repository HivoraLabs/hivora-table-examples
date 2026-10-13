#!/usr/bin/env bash
# Servers/employees currently in the floor plan.
# Usage: HIVORA_API_KEY=htk_sbx_... ./servers.sh
set -euo pipefail

: "${HIVORA_API_KEY:?Set HIVORA_API_KEY to your sandbox API key}"
BASE_URL="${HIVORA_BASE_URL:-https://sandbox.hivoralabs.com/api/v1}"

curl -sS -w '\nHTTP %{http_code}\n' \
  -H "X-API-Key: $HIVORA_API_KEY" \
  "$BASE_URL/servers"
