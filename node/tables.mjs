#!/usr/bin/env node
// List tables against the Hivora Table Open API.
// No dependencies beyond Node 18+ (uses global fetch).
//
// Usage:
//   HIVORA_API_KEY=htk_sbx_... node tables.mjs
//   HIVORA_API_KEY=htk_sbx_... node tables.mjs t-1        # get one table
//   HIVORA_API_KEY=htk_sbx_... HIVORA_BASE_URL=... node tables.mjs

const BASE_URL = process.env.HIVORA_BASE_URL ?? 'https://sandbox.hivoralabs.com/api/v1';
const API_KEY = process.env.HIVORA_API_KEY;

if (!API_KEY) {
  console.error('Set HIVORA_API_KEY in the environment.');
  process.exit(1);
}

async function main() {
  const tableId = process.argv[2];
  const url = tableId ? `${BASE_URL}/tables/${tableId}` : `${BASE_URL}/tables`;

  const response = await fetch(url, {
    headers: { 'X-API-Key': API_KEY },
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
