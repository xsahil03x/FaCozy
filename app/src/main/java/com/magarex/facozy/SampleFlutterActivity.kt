package com.magarex.facozy

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import org.json.JSONObject

class SampleFlutterActivity : FlutterActivity() {

    companion object {
        fun startActivityForResult(
            context: MainActivity,
            initialRoute: String? = null,
            args: String? = null,
            requestCode: Int
        ) {
            val intent = Intent(context, SampleFlutterActivity::class.java)
            if (initialRoute != null) intent.putExtra("initialRoute", initialRoute)
            if (args != null) intent.putExtra("args", args)
            context.startActivityForResult(intent, requestCode)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val initialRoute = intent?.extras?.getString("initialRoute")
        val args = intent?.extras?.getString("args")

        (application as? FaCozyApplication)?.methodChannel?.also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    // manage method calls here
                    "CalculationResult" -> {
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
                    "NetworkCallResult" -> {
                        val resultStr = call.arguments.toString()
                        val resultJson = JSONObject(resultStr)
                        val ip = resultJson.getString("ip")

                        val intent = Intent()
                        intent.putExtra("ip", ip)
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
            if (initialRoute != null) {
                val data: JSONObject = JSONObject().apply {
                    put("InitialRoute", initialRoute)
                }
                if (args != null) data.put("Arguments", args)
                it.invokeMethod("SetInitialRoute", data.toString())
            }
        }
    }

    override fun getCachedEngineId(): String? = "fa_cozy_engine"

}