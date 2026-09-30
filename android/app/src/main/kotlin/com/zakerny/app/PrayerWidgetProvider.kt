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

                val city = prefs.getString("city", "موقعي الحالي") ?: "موقعي الحالي"
                val nextName = prefs.getString("next_prayer_name", "الفجر") ?: "الفجر"
                val nextTime = prefs.getString("next_prayer_time", "٠٥:٢٤ ص") ?: "٠٥:٢٤ ص"
                val activeKey = prefs.getString("active_prayer_key", "fajr") ?: "fajr"

                val fajr = prefs.getString("fajr", "٠٥:٢٤ ص") ?: "٠٥:٢٤ ص"
                val sunrise = prefs.getString("sunrise", "٠٦:٥١ ص") ?: "٠٦:٥١ ص"
                val dhuhr = prefs.getString("dhuhr", "١٢:٤٩ م") ?: "١٢:٤٩ م"
                val asr = prefs.getString("asr", "٠٤:١٠ م") ?: "٠٤:١٠ م"
                val maghrib = prefs.getString("maghrib", "٠٦:٤٣ م") ?: "٠٦:٤٣ م"
                val isha = prefs.getString("isha", "٠٨:٠١ م") ?: "٠٨:٠١ م"

                val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout)

                // Header Texts
                views.setTextViewText(R.id.widget_subtitle, "$city • الشروق $sunrise")
                views.setTextViewText(R.id.widget_next_badge, "$nextName $nextTime")

                // Times for 5 prayers
                views.setTextViewText(R.id.widget_fajr_time, fajr)
                views.setTextViewText(R.id.widget_dhuhr_time, dhuhr)
                views.setTextViewText(R.id.widget_asr_time, asr)
                views.setTextViewText(R.id.widget_maghrib_time, maghrib)
                views.setTextViewText(R.id.widget_isha_time, isha)

                // Active / Inactive states via ImageView backgrounds (100% RemoteViews safe)
                val inactiveBg = R.drawable.prayer_inactive_item_bg
                val activeBg = R.drawable.prayer_active_item_bg

                val colorWhite = Color.parseColor("#FFFFFF")
                val colorSlateDark = Color.parseColor("#0F172A")
                val colorSlateMuted = Color.parseColor("#334155")

                val prayers = listOf(
                    PrayerItemData("fajr", R.id.widget_fajr_bg, R.id.widget_fajr_name, R.id.widget_fajr_time),
                    PrayerItemData("dhuhr", R.id.widget_dhuhr_bg, R.id.widget_dhuhr_name, R.id.widget_dhuhr_time),
                    PrayerItemData("asr", R.id.widget_asr_bg, R.id.widget_asr_name, R.id.widget_asr_time),
                    PrayerItemData("maghrib", R.id.widget_maghrib_bg, R.id.widget_maghrib_name, R.id.widget_maghrib_time),
                    PrayerItemData("isha", R.id.widget_isha_bg, R.id.widget_isha_name, R.id.widget_isha_time)
                )

                for (p in prayers) {
                    val isActive = p.key.equals(activeKey, ignoreCase = true)
                    views.setImageViewResource(p.bgId, if (isActive) activeBg else inactiveBg)
                    views.setTextColor(p.nameId, if (isActive) colorWhite else colorSlateMuted)
                    views.setTextColor(p.timeId, if (isActive) colorWhite else colorSlateDark)
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
        val nameId: Int,
        val timeId: Int
    )
}
