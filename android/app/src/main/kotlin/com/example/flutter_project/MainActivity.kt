package com.example.flutter_project

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.gemzi/upi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchUpi") {
                val url = call.argument<String>("url")
                val appPackage = call.argument<String>("package")
                
                if (url != null) {
                    val intent = Intent(Intent.ACTION_VIEW)
                    intent.data = Uri.parse(url)
                    if (appPackage != null) {
                        intent.setPackage(appPackage)
                    }
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "App not found.", null)
                    }
                } else {
                    result.error("INVALID_ARGS", "URL is missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
