package com.zakerny.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews

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

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            val city = prefs.getString("city", "القاهرة") ?: "القاهرة"
            val nextName = prefs.getString("next_prayer_name", "العصر") ?: "العصر"
            val nextTime = prefs.getString("next_prayer_time", "03:18 م") ?: "03:18 م"
            val activeKey = prefs.getString("active_prayer_key", "asr") ?: "asr"

            val fajr = prefs.getString("fajr", "04:30") ?: "04:30"
            val sunrise = prefs.getString("sunrise", "05:55") ?: "05:55"
            val dhuhr = prefs.getString("dhuhr", "11:53") ?: "11:53"
            val asr = prefs.getString("asr", "03:18") ?: "03:18"
            val maghrib = prefs.getString("maghrib", "05:42") ?: "05:42"
            val isha = prefs.getString("isha", "07:00") ?: "07:00"

            val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout)

            // Header Texts
            views.setTextViewText(R.id.widget_subtitle, "$city • مواقيت اليوم المبارك")
            views.setTextViewText(R.id.widget_next_badge, "$nextName $nextTime")

            // Times
            views.setTextViewText(R.id.widget_fajr_time, fajr)
            views.setTextViewText(R.id.widget_sunrise_time, sunrise)
            views.setTextViewText(R.id.widget_dhuhr_time, dhuhr)
            views.setTextViewText(R.id.widget_asr_time, asr)
            views.setTextViewText(R.id.widget_maghrib_time, maghrib)
            views.setTextViewText(R.id.widget_isha_time, isha)

            // Reset all containers to inactive / highlight active
            val inactiveBg = R.drawable.prayer_inactive_item_bg
            val activeBg = R.drawable.prayer_active_item_bg

            val colorWhite = Color.parseColor("#FFFFFF")
            val colorSlateDark = Color.parseColor("#0F172A")
            val colorSlateMuted = Color.parseColor("#475569")

            val prayerContainers = listOf(
                Triple("fajr", R.id.widget_fajr_container, Pair(R.id.widget_fajr_name, R.id.widget_fajr_time)),
                Triple("sunrise", R.id.widget_sunrise_container, Pair(R.id.widget_sunrise_name, R.id.widget_sunrise_time)),
                Triple("dhuhr", R.id.widget_dhuhr_container, Pair(R.id.widget_dhuhr_name, R.id.widget_dhuhr_time)),
                Triple("asr", R.id.widget_asr_container, Pair(R.id.widget_asr_name, R.id.widget_asr_time)),
                Triple("maghrib", R.id.widget_maghrib_container, Pair(R.id.widget_maghrib_name, R.id.widget_maghrib_time)),
                Triple("isha", R.id.widget_isha_container, Pair(R.id.widget_isha_name, R.id.widget_isha_time))
            )

            for ((key, containerId, textIds) in prayerContainers) {
                val isActive = key.equals(activeKey, ignoreCase = true)
                views.setInt(containerId, "setBackgroundResource", if (isActive) activeBg else inactiveBg)
                views.setTextColor(textIds.first, if (isActive) colorWhite else colorSlateMuted)
                views.setTextColor(textIds.second, if (isActive) colorWhite else colorSlateDark)
            }

            // Click pending intent to open app at prayer times
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("route", "/prayers")
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, PrayerWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            if (allWidgetIds != null && allWidgetIds.isNotEmpty()) {
                for (id in allWidgetIds) {
                    updateAppWidget(context, appWidgetManager, id)
                }
            }
        }
    }
}
