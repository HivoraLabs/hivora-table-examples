// Standard Gradle build for the Hivora Table Kotlin/OkHttp example.
//
// This mirrors how you'd wire the client into an Android app's Gradle
// build (the dependency and Kotlin version are the same either way);
// the `application` plugin here just makes `HivoraTableClient.kt`'s
// `main()` runnable from the command line for local testing.
plugins {
    kotlin("jvm") version "2.0.20"
    application
}

group = "com.hivoralabs.table"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}

application {
    mainClass.set("com.hivoralabs.table.HivoraTableClientKt")
}

kotlin {
    jvmToolchain(17)
}
