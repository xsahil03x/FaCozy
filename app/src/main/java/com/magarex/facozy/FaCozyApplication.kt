package com.magarex.facozy

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

const val METHOD_CHANNEL_NAME = "fa_cozy_method_channel"

class FaCozyApplication : Application() {
    lateinit var flutterEngine: FlutterEngine
    lateinit var methodChannel: MethodChannel

    override fun onCreate() {
        super.onCreate()

        // Instantiate a FlutterEngine.
        flutterEngine = FlutterEngine(this)

        // Configure an initial route.
        flutterEngine.navigationChannel.setInitialRoute("/")

        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        // Create a global methodChannel which can be used by whole app
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor,
            METHOD_CHANNEL_NAME
        )

        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache
            .getInstance()
            .put("fa_cozy_engine", flutterEngine)
    }
}