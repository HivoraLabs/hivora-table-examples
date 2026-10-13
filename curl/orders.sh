#!/usr/bin/env bash
# Send an order to a table — the primary integration endpoint for ordering
# pads. Always send a unique X-Idempotency-Key per *logical* order attempt;
# retrying the exact same key returns the original result instead of
# creating a duplicate order (see the Partner Requirements guide).
#
# Usage:
#   HIVORA_API_KEY=htk_sbx_... ./orders.sh <table-id>
#   HIVORA_API_KEY=htk_sbx_... ./orders.sh <table-id> <idempotency-key>   # reuse a key to test idempotency
set -euo pipefail

: "${HIVORA_API_KEY:?Set HIVORA_API_KEY to your sandbox API key}"
BASE_URL="${HIVORA_BASE_URL:-https://sandbox.hivoralabs.com/api/v1}"

table_id="${1:?Usage: $0 <table-id> [idempotency-key]}"
idem_key="${2:-$(uuidgen)}"

echo "Using X-Idempotency-Key: $idem_key" >&2

curl -sS -w '\nHTTP %{http_code}\n' -X POST \
  -H "X-API-Key: $HIVORA_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-Idempotency-Key: $idem_key" \
  -d "{
        \"tableId\": \"$table_id\",
        \"guestCount\": 2,
        \"source\": \"examples-repo\",
        \"items\": [
          { \"name\": \"Bibimbap\", \"quantity\": 2, \"price\": 1200 }
        ]
      }" \
  "$BASE_URL/orders"
