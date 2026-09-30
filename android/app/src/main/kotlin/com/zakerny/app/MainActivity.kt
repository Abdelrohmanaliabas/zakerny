package com.zakerny.app

import android.content.Context
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val WIDGET_CHANNEL = "com.zakerny.app/prayer_widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                val data = call.arguments as? Map<*, *>
                if (data != null) {
                    val prefs = getSharedPreferences(PrayerWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    val editor = prefs.edit()
                    for ((key, value) in data) {
                        if (key is String && value is String) {
                            editor.putString(key, value)
                        }
                    }
                    editor.apply()
                    PrayerWidgetProvider.updateAllWidgets(this)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGS", "Widget data is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
