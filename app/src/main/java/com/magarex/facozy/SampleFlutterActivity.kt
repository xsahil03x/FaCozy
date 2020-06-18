package com.magarex.facozy

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class SampleFlutterActivity : FlutterActivity() {

    companion object {
        const val METHOD_CHANNEL_NAME = "fa_cozy_method_channel"
        fun startActivityForResult(context: MainActivity, first: Int, second: Int) {
            val intent = Intent(context, SampleFlutterActivity::class.java)
            intent.putExtra("num1", first)
            intent.putExtra("num2", second)
            context.startActivityForResult(intent, MainActivity.ACTIVITY_REQUEST_CODE)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val num1 = intent?.extras?.getInt("num1", 0)
        val num2 = intent?.extras?.getInt("num2", 0)

        if (flutterEngine?.dartExecutor != null) {
            MethodChannel(
                flutterEngine!!.dartExecutor,
                METHOD_CHANNEL_NAME
            ).also {
                it.setMethodCallHandler { call, result ->
                    when (call.method) {
                        // manage method calls here
                        "FromClientToHost" -> {
                            val resultStr = call.arguments.toString()
                            val resultJson = JSONObject(resultStr)
                            val res = resultJson.getInt("result")
                            val operation = resultJson.getInt("operation")

                            val intent = Intent()
                            intent.putExtra("result", res)
                            intent.putExtra("operation", operation)
                            setResult(Activity.RESULT_OK, intent)
                            finish()
                        }
                        else -> {
                            result.notImplemented()
                            setResult(Activity.RESULT_CANCELED)
                            finish()
                        }
                    }
                }
                it.invokeMethod(
                    "FromHostToClient", JSONObject().apply {
                        put("num1", num1)
                        put("num2", num2)
                    }.toString()
                )
            }
        }
    }

    override fun getCachedEngineId(): String? = "fa_cozy_engine"

}