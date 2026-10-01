package com.zakerny.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
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

                val city = prefs.getString("city", "مدينة السادات") ?: "مدينة السادات"
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

                // Render high-fidelity 3D Al-Fajia Clock bitmap
                val renderedBitmap = renderClockBitmap(
                    context = context,
                    city = city,
                    mainTime = mainTime,
                    gregDate = gregDate,
                    hijriDate = hijriDate,
                    temp = temp,
                    iqamah = iqamah,
                    fajr = fajr,
                    sunrise = sunrise,
                    dhuhr = dhuhr,
                    asr = asr,
                    maghrib = maghrib,
                    isha = isha,
                    activeKey = activeKey
                )

                views.setImageViewBitmap(R.id.widget_clock_image, renderedBitmap)

                // Click intent to open app at prayer clock
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
                views.setOnClickPendingIntent(R.id.widget_clock_image, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Error updating prayer app widget: ${e.message}", e)
            }
        }

        private fun renderClockBitmap(
            context: Context,
            city: String,
            mainTime: String,
            gregDate: String,
            hijriDate: String,
            temp: String,
            iqamah: String,
            fajr: String,
            sunrise: String,
            dhuhr: String,
            asr: String,
            maghrib: String,
            isha: String,
            activeKey: String
        ): Bitmap {
            val options = BitmapFactory.Options().apply {
                inPreferredConfig = Bitmap.Config.ARGB_8888
                inMutable = true
            }
            val template = BitmapFactory.decodeResource(context.resources, R.drawable.al_fajia_widget_base, options)
            val bitmap = if (template.isMutable) template else template.copy(Bitmap.Config.ARGB_8888, true)
            val canvas = Canvas(bitmap)

            val redColor = Color.parseColor("#FF2222")
            val amberColor = Color.parseColor("#FFA028")
            val cityColor = Color.parseColor("#7A4F18")

            // 1. Main Time Clock (dead center inside the glossy central bezel: x=394, y=460)
            val mainTimePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = redColor
                typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
                textAlign = Paint.Align.CENTER
                textSize = 72f
            }
            drawCenteredText(canvas, mainTime, 394f, 460f, mainTimePaint)

            // 2. Date Matrix (centered at x=394, y=578)
            val datePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = amberColor
                typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
                textAlign = Paint.Align.CENTER
                textSize = 26f
            }
            val displayDate = if (gregDate.length > 20) gregDate.substring(0, 20) else gregDate
            drawCenteredText(canvas, displayDate, 394f, 578f, datePaint)

            // 3. City Name (under date display, above Fajr: x=392, y=633)
            val cityPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = cityColor
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textAlign = Paint.Align.CENTER
                textSize = 22f
            }
            val shortCity = if (city.length > 20) city.substring(0, 20) else city
            drawCenteredText(canvas, shortCity, 392f, 633f, cityPaint)

            // 4. 6 Prayer Times (inside individual bezels: x=392, y = 685, 773, 861, 949, 1036, 1123)
            val prayerTimePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = redColor
                typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
                textAlign = Paint.Align.CENTER
                textSize = 38f
            }

            val activeDotPaintGlow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#99FF4444")
                style = Paint.Style.FILL
            }
            val activeDotPaintCore = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#FFFF2222")
                style = Paint.Style.FILL
            }
            val activeDotPaintHighlight = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#FFFFE0E0")
                style = Paint.Style.FILL
            }

            val prayerList = listOf(
                Pair("fajr", fajr),
                Pair("sunrise", sunrise),
                Pair("dhuhr", dhuhr),
                Pair("asr", asr),
                Pair("maghrib", maghrib),
                Pair("isha", isha)
            )
            val prayerY = listOf(685f, 773f, 861f, 949f, 1036f, 1123f)

            for (i in prayerList.indices) {
                val (key, time) = prayerList[i]
                val cy = prayerY[i]
                drawCenteredText(canvas, time, 392f, cy, prayerTimePaint)

                // Active red LED indicator dot
                val isRowActive = key.equals(activeKey, ignoreCase = true)
                if (isRowActive) {
                    val dotCx = 496f
                    canvas.drawCircle(dotCx, cy, 10f, activeDotPaintGlow)
                    canvas.drawCircle(dotCx, cy, 7f, activeDotPaintCore)
                    canvas.drawCircle(dotCx - 2f, cy - 2f, 2.5f, activeDotPaintHighlight)
                }
            }

            // Downscale to 384x644 for optimal Android RemoteViews memory and crystal clarity
            return Bitmap.createScaledBitmap(bitmap, 384, 644, true)
        }

        private fun drawCenteredText(canvas: Canvas, text: String, cx: Float, cy: Float, paint: Paint) {
            val fm = paint.fontMetrics
            val baseline = cy - (fm.ascent + fm.descent) / 2f
            canvas.drawText(text, cx, baseline, paint)
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
}
