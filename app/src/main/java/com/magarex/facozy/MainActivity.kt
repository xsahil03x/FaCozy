package com.magarex.facozy

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View.GONE
import android.view.View.VISIBLE
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import io.flutter.plugin.common.MethodChannel
import kotlinx.android.synthetic.main.activity_main.*
import org.json.JSONObject

class MainActivity : AppCompatActivity() {

    companion object {
        const val CALCULATION_REQUEST_CODE = 333
        const val NETWORK_CALL_REQUEST_CODE = 777
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        btn_calculate.setOnClickListener {
            val pair = isInputValid()
            if (pair != null) {
                SampleFlutterActivity.startActivityForResult(
                    this, initialRoute = "/calculation", args = JSONObject().apply {
                        put("num1", pair.first)
                        put("num2", pair.second)
                    }.toString(),
                    requestCode = CALCULATION_REQUEST_CODE
                )
            }
        }
        btn_network_call.setOnClickListener {
            SampleFlutterActivity.startActivityForResult(
                this,
                "/network_call",
                requestCode = NETWORK_CALL_REQUEST_CODE
            )
        }
        btn_background_network_call.setOnClickListener{
            networkCallProgressBar.visibility = VISIBLE
            tvBackgroundNetworkCallResult.visibility = GONE
            (application as FaCozyApplication).methodChannel.invokeMethod(
                "GetIpAddress", null, object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        if (result != null) {
                            networkCallProgressBar.visibility = GONE
                            tvBackgroundNetworkCallResult.visibility = VISIBLE
                            tvBackgroundNetworkCallResult.text = result as String
                        }
                    }

                    override fun error(
                        errorCode: String?,
                        errorMessage: String?,
                        errorDetails: Any?
                    ) {
                        if (errorMessage != null) {
                            networkCallProgressBar.visibility = GONE
                            tvBackgroundNetworkCallResult.visibility = VISIBLE
                            tvBackgroundNetworkCallResult.text = errorMessage
                        }
                    }

                    override fun notImplemented() {
                        networkCallProgressBar.visibility = GONE
                        tvBackgroundNetworkCallResult.visibility = VISIBLE
                        tvBackgroundNetworkCallResult.text = "GetIpAddress Not Implemented yet"
                    }
                }
            )
        }
    }

    @SuppressLint("SetTextI18n")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        when (resultCode == Activity.RESULT_OK) {
            requestCode == CALCULATION_REQUEST_CODE -> {
                print(data)
                val result = data?.extras?.getInt("result")
                val operation = data?.extras?.getInt("operation") ?: 0
                val text = "${Operation.values()[operation].name} of the entered numbers is $result"
                tvResult.text = text
            }
            requestCode == NETWORK_CALL_REQUEST_CODE -> {
                print(data)
                val ip = data?.extras?.getString("ip")
                tvNetworkCallResult.text = ip
            }
            else -> tvResult.text = "Could not perform the operation"

        }
        super.onActivityResult(requestCode, resultCode, data)
    }


    private fun isInputValid(): Pair<Int, Int>? {
        val number1 = et_number_1.text.toString()
        val number2 = et_number_2.text.toString()

        when {
            number1.isBlank() -> showToast("Please enter first number")
            number2.isBlank() -> showToast("Please enter second number")
            else -> return Pair(number1.toInt(), number2.toInt())
        }

        return null
    }

    private fun showToast(msg: String) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
    }

    private enum class Operation {
        Addition,
        Multiplication,
        Division,
        Subtraction,
    }
}
