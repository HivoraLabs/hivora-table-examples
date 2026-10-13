package com.hivoralabs.table

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.UUID
import java.util.concurrent.TimeUnit

/**
 * Minimal OkHttp client for the Hivora Table Open API.
 *
 * Partner tablet apps are most commonly Android/Kotlin, so this is the
 * primary reference implementation among the examples. It intentionally
 * has no framework dependencies beyond OkHttp — drop it into an existing
 * Android app's networking layer as-is, or use it as a template.
 *
 * Every request reads the API key from the constructor (never hard-code
 * it) and targets the sandbox by default.
 */
class HivoraTableClient(
    private val apiKey: String,
    private val baseUrl: String = "https://sandbox.hivoralabs.com/api/v1",
    private val client: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build(),
) {
    private val jsonMediaType = "application/json".toMediaType()

    /** GET /tables — list every table with current status and open-order summary. */
    fun listTables(): String = executeRequest(
        Request.Builder()
            .url("$baseUrl/tables")
            .header("X-API-Key", apiKey)
            .get()
            .build()
    )

    /** GET /tables/{id} — a single table's detail. */
    fun getTable(tableId: String): String = executeRequest(
        Request.Builder()
            .url("$baseUrl/tables/$tableId")
            .header("X-API-Key", apiKey)
            .get()
            .build()
    )

    /**
     * POST /orders — send an order to a table.
     *
     * [idempotencyKey] MUST be unique per logical order attempt and
     * reused verbatim on any retry of that same attempt (e.g. after a
     * timeout or 5xx). Retrying with the same key returns the original
     * result rather than creating a second order. Defaults to a random
     * UUID per call, which is correct for a brand-new order — callers
     * that retry must pass the same key back in explicitly.
     */
    fun sendOrder(
        tableId: String,
        items: List<OrderItem>,
        guestCount: Int = 1,
        source: String = "kotlin-example",
        idempotencyKey: String = UUID.randomUUID().toString(),
    ): String {
        val itemsJson = items.joinToString(",") { item ->
            """{"name":"${item.name}","quantity":${item.quantity},"price":${item.price}}"""
        }
        val payload = """
            {"tableId":"$tableId","guestCount":$guestCount,"source":"$source","items":[$itemsJson]}
        """.trimIndent()

        val request = Request.Builder()
            .url("$baseUrl/orders")
            .header("X-API-Key", apiKey)
            .header("X-Idempotency-Key", idempotencyKey)
            .post(payload.toRequestBody(jsonMediaType))
            .build()

        return executeRequest(request)
    }

    private fun executeRequest(request: Request): String {
        client.newCall(request).execute().use { response ->
            val body = response.body?.string().orEmpty()
            return "HTTP ${response.code}\n$body"
        }
    }

    data class OrderItem(val name: String, val quantity: Int, val price: Int)
}

/**
 * Runnable smoke test: `list tables` then `send an order` with an
 * idempotency key, mirroring the curl/ and node/ examples.
 *
 * Usage:
 *   HIVORA_API_KEY=htk_sbx_... kotlinc ... -include-runtime -d client.jar
 *   java -jar client.jar <table-id>
 */
fun main(args: Array<String>) {
    val apiKey = System.getenv("HIVORA_API_KEY")
        ?: error("Set HIVORA_API_KEY in the environment.")
    val baseUrl = System.getenv("HIVORA_BASE_URL") ?: "https://sandbox.hivoralabs.com/api/v1"
    val tableId = args.getOrNull(0) ?: error("Usage: <table-id> [idempotency-key]")
    val idempotencyKey = args.getOrNull(1) ?: UUID.randomUUID().toString()

    val client = HivoraTableClient(apiKey = apiKey, baseUrl = baseUrl)

    println("=== listTables() ===")
    println(client.listTables())

    println("\n=== getTable(\"$tableId\") ===")
    println(client.getTable(tableId))

    println("\n=== sendOrder(\"$tableId\") — X-Idempotency-Key: $idempotencyKey ===")
    println(
        client.sendOrder(
            tableId = tableId,
            items = listOf(HivoraTableClient.OrderItem("Bibimbap", 2, 1200)),
            guestCount = 2,
            idempotencyKey = idempotencyKey,
        )
    )
}
