# Hivora Table API examples

Integration examples for the [Hivora Table](https://docs.hivoralabs.com) Open
API — the floor-plan / table-state layer for Clover restaurants. If you're
building an ordering pad, kiosk, or any system that needs to push orders
onto tables or read the current floor plan, start here.

Full documentation, including the API reference, guides, and a Postman
collection, is at **[docs.hivoralabs.com](https://docs.hivoralabs.com)**.

## Get a key

Sign in at **[developers.hivoralabs.com](https://developers.hivoralabs.com)**,
create an organization, and apply for Hivora Table. Once the application is
approved you issue the sandbox key (`htk_sbx_...`) yourself, from the portal.
It is shown in full exactly once — store it securely (server-side only, never
bundled into a client app).

## What's here

| Folder | Language | Notes |
|---|---|---|
| [`curl/`](./curl) | Shell | One script per endpoint group. No setup beyond `curl` and (for `orders.sh`) `uuidgen`. |
| [`kotlin/`](./kotlin) | Kotlin + OkHttp | The primary reference implementation — partner tablet apps are most commonly Android. |
| [`node/`](./node) | Node.js (fetch) | No dependencies beyond Node 18+. |

Every example, in every language, covers at minimum:

- **List tables** — `GET /tables`
- **Send an order** — `POST /orders`, including a proper `X-Idempotency-Key`

All examples target the sandbox by default (`https://sandbox.hivoralabs.com/api/v1`)
and read the API key from an environment variable — never hard-coded.

## Running the examples

Set your key once per shell session:

```bash
export HIVORA_API_KEY=htk_sbx_...
```

**curl:**

```bash
cd curl
./health.sh
./tables.sh list
./tables.sh get t-1
./orders.sh t-1                 # sends with a fresh idempotency key
./orders.sh t-1 my-fixed-key    # retry with the same key: no duplicate order
```

**Node.js** (18+, no install needed):

```bash
cd node
node tables.mjs
node tables.mjs t-1
node orders.mjs t-1
node orders.mjs t-1 my-fixed-key
```

**Kotlin:** see [`kotlin/README.md`](./kotlin/README.md) for both the Gradle
and no-Gradle setup.

## Idempotency

`POST /orders` requires a unique `X-Idempotency-Key` per order attempt.
Retrying the exact same key returns the original result instead of creating
a second order — this is the correct way to handle a timeout or a `5xx`
without risking a duplicate. See the
[Partner Requirements guide](https://docs.hivoralabs.com/hivora-table/guides/partner-requirements)
for the full retry policy.

## Sandbox notes

The sandbox demo merchant, "Hivora Demo Kitchen," resets nightly at 4am US Pacific.
Don't build anything that depends on state persisting across that boundary.
See the [Sandbox guide](https://docs.hivoralabs.com/hivora-table/guides/sandbox) for
details.
