#!/usr/bin/env bash
# Table endpoints: list, get one, seat/occupy, release, and update guest count.
#
# Requires HIVORA_API_KEY in the environment. Optionally set HIVORA_BASE_URL
# (defaults to the sandbox) and TABLE_ID (defaults to the sandbox's t-5,
# which starts "available" so occupy/release don't collide with other
# partners hitting the shared sandbox at the same time).
#
# Usage:
#   HIVORA_API_KEY=htk_sbx_... ./tables.sh list
#   HIVORA_API_KEY=htk_sbx_... ./tables.sh get t-1
#   HIVORA_API_KEY=htk_sbx_... ./tables.sh occupy t-5
#   HIVORA_API_KEY=htk_sbx_... ./tables.sh guest-count t-5 3
#   HIVORA_API_KEY=htk_sbx_... ./tables.sh release t-5
set -euo pipefail

: "${HIVORA_API_KEY:?Set HIVORA_API_KEY to your sandbox API key}"
BASE_URL="${HIVORA_BASE_URL:-https://sandbox.hivoralabs.com/api/v1}"

cmd="${1:-list}"

case "$cmd" in
  list)
    curl -sS -w '\nHTTP %{http_code}\n' \
      -H "X-API-Key: $HIVORA_API_KEY" \
      "$BASE_URL/tables"
    ;;
  get)
    id="${2:?Usage: $0 get <table-id>}"
    curl -sS -w '\nHTTP %{http_code}\n' \
      -H "X-API-Key: $HIVORA_API_KEY" \
      "$BASE_URL/tables/$id"
    ;;
  occupy)
    id="${2:?Usage: $0 occupy <table-id>}"
    curl -sS -w '\nHTTP %{http_code}\n' -X POST \
      -H "X-API-Key: $HIVORA_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{"guestCount": 2, "serverName": "Examples Script", "source": "examples-repo"}' \
      "$BASE_URL/tables/$id/occupy"
    ;;
  release)
    id="${2:?Usage: $0 release <table-id>}"
    curl -sS -w '\nHTTP %{http_code}\n' -X POST \
      -H "X-API-Key: $HIVORA_API_KEY" \
      "$BASE_URL/tables/$id/release"
    ;;
  guest-count)
    id="${2:?Usage: $0 guest-count <table-id> <count>}"
    count="${3:?Usage: $0 guest-count <table-id> <count>}"
    curl -sS -w '\nHTTP %{http_code}\n' -X PATCH \
      -H "X-API-Key: $HIVORA_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"guestCount\": $count}" \
      "$BASE_URL/tables/$id/guest-count"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    echo "Usage: $0 {list|get|occupy|release|guest-count} [table-id] [args...]" >&2
    exit 1
    ;;
esac
