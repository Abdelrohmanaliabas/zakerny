package com.zakerny.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.Log
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE_PRAYER_WIDGET) {
            updateAllWidgets(context)
        }
    }

    companion object {
        const val PREFS_NAME = "prayer_widget_prefs"
        const val ACTION_UPDATE_PRAYER_WIDGET = "com.zakerny.app.ACTION_UPDATE_PRAYER_WIDGET"
        private const val TAG = "PrayerWidgetProvider"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

                val city = prefs.getString("city", "القاهرة") ?: "القاهرة"
                val activeKey = prefs.getString("active_prayer_key", "fajr") ?: "fajr"

                val fajr = prefs.getString("fajr", "04:22") ?: "04:22"
                val sunrise = prefs.getString("sunrise", "05:39") ?: "05:39"
                val dhuhr = prefs.getString("dhuhr", "11:49") ?: "11:49"
                val asr = prefs.getString("asr", "03:16") ?: "03:16"
                val maghrib = prefs.getString("maghrib", "05:57") ?: "05:57"
                val isha = prefs.getString("isha", "07:27") ?: "07:27"

                val temp = prefs.getString("temp", "22°C") ?: "22°C"
                val iqamah = prefs.getString("iqamah", "21°F") ?: "21°F"
                val hijriDate = prefs.getString("hijri_date", "١٤ ربيع الأول ١٤٤٦") ?: "١٤ ربيع الأول ١٤٤٦"

                val now = Date()
                val gregFormatter = SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH)
                val timeFormatter = SimpleDateFormat("hh:mm", Locale.ENGLISH)
                val gregDate = prefs.getString("greg_date", gregFormatter.format(now).uppercase()) ?: gregFormatter.format(now).uppercase()
                val mainTime = prefs.getString("current_time", timeFormatter.format(now)) ?: timeFormatter.format(now)

                val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout)

                // Top Bar
                views.setTextViewText(R.id.widget_temp, temp)
                views.setTextViewText(R.id.widget_iqamah, iqamah)
                views.setTextViewText(R.id.widget_city, "ساعة الحرمين • $city")

                // Main Clock
                views.setTextViewText(R.id.widget_main_time, mainTime)

                // Dates
                views.setTextViewText(R.id.widget_date_hijri, hijriDate)
                views.setTextViewText(R.id.widget_date_greg, gregDate)

                // Prayers setup
                views.setTextViewText(R.id.widget_fajr_time, fajr)
                views.setTextViewText(R.id.widget_shuroq_time, sunrise)
                views.setTextViewText(R.id.widget_dhuhr_time, dhuhr)
                views.setTextViewText(R.id.widget_asr_time, asr)
                views.setTextViewText(R.id.widget_maghrib_time, maghrib)
                views.setTextViewText(R.id.widget_isha_time, isha)

                val prayers = listOf(
                    PrayerItemData("fajr", R.id.widget_fajr_bg, R.id.widget_fajr_led, R.id.widget_fajr_en, R.id.widget_fajr_name, R.id.widget_fajr_time),
                    PrayerItemData("sunrise", R.id.widget_shuroq_bg, R.id.widget_shuroq_led, R.id.widget_shuroq_en, R.id.widget_shuroq_name, R.id.widget_shuroq_time),
                    PrayerItemData("dhuhr", R.id.widget_dhuhr_bg, R.id.widget_dhuhr_led, R.id.widget_dhuhr_en, R.id.widget_dhuhr_name, R.id.widget_dhuhr_time),
                    PrayerItemData("asr", R.id.widget_asr_bg, R.id.widget_asr_led, R.id.widget_asr_en, R.id.widget_asr_name, R.id.widget_asr_time),
                    PrayerItemData("maghrib", R.id.widget_maghrib_bg, R.id.widget_maghrib_led, R.id.widget_maghrib_en, R.id.widget_maghrib_name, R.id.widget_maghrib_time),
                    PrayerItemData("isha", R.id.widget_isha_bg, R.id.widget_isha_led, R.id.widget_isha_en, R.id.widget_isha_name, R.id.widget_isha_time)
                )

                val activeBg = R.drawable.prayer_active_row_bg
                val inactiveBg = R.drawable.prayer_inactive_row_bg
                val activeLed = R.drawable.prayer_led_active
                val inactiveLed = R.drawable.prayer_led_inactive

                val colorNavy = Color.parseColor("#0F2440")
                val colorGoldHighlight = Color.parseColor("#B45309")
                val colorLed = Color.parseColor("#FF2222")

                for (p in prayers) {
                    val isActive = p.key.equals(activeKey, ignoreCase = true)
                    views.setImageViewResource(p.bgId, if (isActive) activeBg else inactiveBg)
                    views.setImageViewResource(p.ledId, if (isActive) activeLed else inactiveLed)
                    views.setTextColor(p.enId, if (isActive) colorGoldHighlight else colorNavy)
                    views.setTextColor(p.nameId, if (isActive) colorGoldHighlight else colorNavy)
                    views.setTextColor(p.timeId, colorLed)
                }

                // Click pending intent to open app at prayer clock
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("route", "/prayer-clock")
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Error updating prayer app widget: ${e.message}", e)
            }
        }

        fun updateAllWidgets(context: Context) {
            try {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val thisWidget = ComponentName(context, PrayerWidgetProvider::class.java)
                val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                if (allWidgetIds != null && allWidgetIds.isNotEmpty()) {
                    for (id in allWidgetIds) {
                        updateAppWidget(context, appWidgetManager, id)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error updating all widgets: ${e.message}", e)
            }
        }
    }

    private data class PrayerItemData(
        val key: String,
        val bgId: Int,
        val ledId: Int,
        val enId: Int,
        val nameId: Int,
        val timeId: Int
    )
}
