#!/usr/bin/env node
// Send an order to a table, with a proper idempotency key.
// No dependencies beyond Node 18+ (uses global fetch and crypto.randomUUID).
//
// Usage:
//   HIVORA_API_KEY=htk_sbx_... node orders.mjs <table-id>
//   HIVORA_API_KEY=htk_sbx_... node orders.mjs <table-id> <idempotency-key>   # reuse a key to test idempotency

import { randomUUID } from 'node:crypto';

const BASE_URL = process.env.HIVORA_BASE_URL ?? 'https://sandbox.hivoralabs.com/api/v1';
const API_KEY = process.env.HIVORA_API_KEY;

if (!API_KEY) {
  console.error('Set HIVORA_API_KEY in the environment.');
  process.exit(1);
}

const tableId = process.argv[2];
if (!tableId) {
  console.error('Usage: node orders.mjs <table-id> [idempotency-key]');
  process.exit(1);
}

const idempotencyKey = process.argv[3] ?? randomUUID();

async function main() {
  console.error(`Using X-Idempotency-Key: ${idempotencyKey}`);

  const response = await fetch(`${BASE_URL}/orders`, {
    method: 'POST',
    headers: {
      'X-API-Key': API_KEY,
      'Content-Type': 'application/json',
      'X-Idempotency-Key': idempotencyKey,
    },
    body: JSON.stringify({
      tableId,
      guestCount: 2,
      source: 'examples-repo',
      items: [{ name: 'Bibimbap', quantity: 2, price: 1200 }],
    }),
  });

  const body = await response.json();
  console.log(`HTTP ${response.status}`);
  console.log(JSON.stringify(body, null, 2));

  if (!response.ok) {
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error('Request failed:', err);
  process.exit(1);
});
