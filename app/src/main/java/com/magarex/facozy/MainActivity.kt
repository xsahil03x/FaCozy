package com.magarex.facozy

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    companion object {
        const val ACTIVITY_REQUEST_CODE = 333
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        btn_calculate.setOnClickListener {
            val pair = isInputValid()
            if (pair != null) {
                SampleFlutterActivity.startActivityForResult(this, pair.first, pair.second)
            }
        }
    }

    @SuppressLint("SetTextI18n")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        when (resultCode == Activity.RESULT_OK) {
            requestCode == ACTIVITY_REQUEST_CODE -> {
                print(data)
                val result = data?.extras?.getInt("result")
                val operation = data?.extras?.getInt("operation") ?: 0
                val text = "${Operation.values()[operation].name} of the entered numbers is $result"
                tvResult.text = text
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
