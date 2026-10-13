# Kotlin (OkHttp) example

`HivoraTableClient.kt` is a minimal OkHttp-based client for the Hivora Table
Open API — the reference implementation, since partner tablet apps are most
commonly Android/Kotlin. It covers:

- `listTables()` — `GET /tables`
- `getTable(id)` — `GET /tables/{id}`
- `sendOrder(...)` — `POST /orders`, with a proper `X-Idempotency-Key`

`main()` runs all three against a real table id as a smoke test, printing
each response.

## Run it with Gradle (typical setup)

No wrapper is checked in, so this uses an installed Gradle (8.x):

```bash
export HIVORA_API_KEY=htk_sbx_...
gradle run --args="t-1"
```

## Run it without Gradle

This is exactly how the example was compiled and executed for verification
before it was committed (no Gradle wrapper needed):

```bash
# Fetch OkHttp + Okio once
mkdir -p /tmp/kotlin-jars && cd /tmp/kotlin-jars
curl -sSLO https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/4.12.0/okhttp-4.12.0.jar
curl -sSLO https://repo1.maven.org/maven2/com/squareup/okio/okio-jvm/3.9.0/okio-jvm-3.9.0.jar

# Compile
kotlinc -cp "/tmp/kotlin-jars/okhttp-4.12.0.jar:/tmp/kotlin-jars/okio-jvm-3.9.0.jar" \
  src/main/kotlin/com/hivoralabs/table/HivoraTableClient.kt \
  -include-runtime -d /tmp/hivora-table-client.jar

# Run
export HIVORA_API_KEY=htk_sbx_...
java -cp "/tmp/hivora-table-client.jar:/tmp/kotlin-jars/okhttp-4.12.0.jar:/tmp/kotlin-jars/okio-jvm-3.9.0.jar" \
  com.hivoralabs.table.HivoraTableClientKt t-1
```

## Android

Drop `HivoraTableClient.kt` into your app module as-is and add the same
OkHttp dependency to your module's `build.gradle.kts`. The client has no
Android-specific imports, so it works unchanged in an Activity, a
ViewModel, or a background sync worker — just don't call it from the main
thread (wrap it in a coroutine with `Dispatchers.IO`, as usual for any
blocking network call).
