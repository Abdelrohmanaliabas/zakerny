package com.zakerny.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
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

                val city = prefs.getString("city", "القاهرة") ?: "القاهرة"
                val activeKey = prefs.getString("active_prayer_key", "fajr") ?: "fajr"
                val nextPrayerName = prefs.getString("next_prayer_name", "الفجر") ?: "الفجر"
                val nextPrayerTime = prefs.getString("next_prayer_time", "05:00 ص") ?: "05:00 ص"
                val timeRemaining = prefs.getString("time_remaining", "حان وقتها") ?: "حان وقتها"

                val fajr = prefs.getString("fajr", "04:22") ?: "04:22"
                val sunrise = prefs.getString("sunrise", "05:39") ?: "05:39"
                val dhuhr = prefs.getString("dhuhr", "11:49") ?: "11:49"
                val asr = prefs.getString("asr", "03:16") ?: "03:16"
                val maghrib = prefs.getString("maghrib", "05:57") ?: "05:57"
                val isha = prefs.getString("isha", "07:27") ?: "07:27"

                val hijriDate = prefs.getString("hijri_date", "١٤ ربيع الأول ١٤٤٦ هـ") ?: "١٤ ربيع الأول ١٤٤٦ هـ"
                val dailyDhikr = prefs.getString("daily_dhikr_text", "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ")
                    ?: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ"

                val now = Date()
                val timeFormatter = SimpleDateFormat("hh:mm a", Locale("ar"))
                val mainTime = prefs.getString("current_time", timeFormatter.format(now)) ?: timeFormatter.format(now)

                val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout)

                // Render high-definition luxury Islamic widget bitmap
                val renderedBitmap = renderIslamicPrayerBitmap(
                    city = city,
                    nextPrayerName = nextPrayerName,
                    nextPrayerTime = nextPrayerTime,
                    timeRemaining = timeRemaining,
                    activeKey = activeKey,
                    fajr = fajr,
                    sunrise = sunrise,
                    dhuhr = dhuhr,
                    asr = asr,
                    maghrib = maghrib,
                    isha = isha,
                    hijriDate = hijriDate,
                    mainTime = mainTime,
                    dailyDhikr = dailyDhikr
                )

                views.setImageViewBitmap(R.id.widget_clock_image, renderedBitmap)

                // Click intent to open app at prayer times
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
                views.setOnClickPendingIntent(R.id.widget_clock_image, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Error updating prayer app widget: ${e.message}", e)
            }
        }

        private fun renderIslamicPrayerBitmap(
            city: String,
            nextPrayerName: String,
            nextPrayerTime: String,
            timeRemaining: String,
            activeKey: String,
            fajr: String,
            sunrise: String,
            dhuhr: String,
            asr: String,
            maghrib: String,
            isha: String,
            hijriDate: String,
            mainTime: String,
            dailyDhikr: String
        ): Bitmap {
            val width = 920
            val height = 480
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)

            val goldColor = Color.parseColor("#D4AF37")
            val goldLightColor = Color.parseColor("#FDE68A")
            val emeraldLightColor = Color.parseColor("#34D399")
            val whiteColor = Color.WHITE

            // 1. Background Gradient (Luxury Fatimid Emerald & Obsidian)
            val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    width.toFloat(), 0f, 0f, height.toFloat(),
                    intArrayOf(
                        Color.parseColor("#06231C"),
                        Color.parseColor("#0B382D"),
                        Color.parseColor("#041914")
                    ),
                    null,
                    Shader.TileMode.CLAMP
                )
            }
            val bgRect = RectF(0f, 0f, width.toFloat(), height.toFloat())
            canvas.drawRoundRect(bgRect, 32f, 32f, bgPaint)

            // Outer Golden Border
            val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldColor
                style = Paint.Style.STROKE
                strokeWidth = 3f
                alpha = 200
            }
            val borderRect = RectF(2f, 2f, width - 2f, height - 2f)
            canvas.drawRoundRect(borderRect, 32f, 32f, borderPaint)

            // Inner Fine Golden Inset Border
            val innerBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldColor
                style = Paint.Style.STROKE
                strokeWidth = 1f
                alpha = 60
            }
            val innerBorderRect = RectF(7f, 7f, width - 7f, height - 7f)
            canvas.drawRoundRect(innerBorderRect, 27f, 27f, innerBorderPaint)

            // 2. Header Row (Y: 20 to 65)
            // City & App Name (Right in RTL, x=885 down to x)
            val headerTitlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldLightColor
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textSize = 24f
                textAlign = Paint.Align.RIGHT
            }
            canvas.drawText("🕌 ذكرني • $city", 885f, 48f, headerTitlePaint)

            // Hijri Date (Center, x=460)
            val hijriPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#9AE6B4")
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textSize = 19f
                textAlign = Paint.Align.CENTER
            }
            canvas.drawText(hijriDate, 460f, 48f, hijriPaint)

            // Time / Gregorian (Left, x=35)
            val timePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldLightColor
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textSize = 21f
                textAlign = Paint.Align.LEFT
            }
            canvas.drawText(mainTime, 35f, 48f, timePaint)

            // Divider Line under Header
            val dividerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldColor
                strokeWidth = 1f
                alpha = 70
            }
            canvas.drawLine(25f, 68f, (width - 25).toFloat(), 68f, dividerPaint)

            // 3. Featured Next Prayer Hero Card (Y: 82 to 200)
            val heroRect = RectF(25f, 82f, (width - 25).toFloat(), 200f)
            val heroBgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    heroRect.right, heroRect.top, heroRect.left, heroRect.bottom,
                    intArrayOf(
                        Color.parseColor("#124C3E"),
                        Color.parseColor("#092F26"),
                        Color.parseColor("#062019")
                    ),
                    null,
                    Shader.TileMode.CLAMP
                )
            }
            canvas.drawRoundRect(heroRect, 22f, 22f, heroBgPaint)

            val heroBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldColor
                style = Paint.Style.STROKE
                strokeWidth = 1.8f
                alpha = 180
            }
            canvas.drawRoundRect(heroRect, 22f, 22f, heroBorderPaint)

            // Next Prayer Label & Name (Right side)
            val nextLabelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = emeraldLightColor
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textSize = 18f
                textAlign = Paint.Align.RIGHT
            }
            canvas.drawText("الصلاة القادمة بإذن الله", heroRect.right - 26f, 120f, nextLabelPaint)

            val nextNamePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = whiteColor
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textSize = 36f
                textAlign = Paint.Align.RIGHT
            }
            canvas.drawText(nextPrayerName, heroRect.right - 26f, 168f, nextNamePaint)

            // Next Prayer Time & Countdown Pill (Left side)
            val nextTimePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#FBBF24")
                typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
                textSize = 38f
                textAlign = Paint.Align.LEFT
            }
            canvas.drawText(nextPrayerTime, heroRect.left + 26f, 134f, nextTimePaint)

            // Time Remaining Badge Pill
            if (timeRemaining.isNotEmpty()) {
                val pillTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = Color.parseColor("#042019")
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                    textSize = 17f
                    textAlign = Paint.Align.CENTER
                }
                val pillWidth = pillTextPaint.measureText(timeRemaining) + 28f
                val pillRect = RectF(heroRect.left + 26f, 150f, heroRect.left + 26f + pillWidth, 185f)
                val pillBgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = goldLightColor
                }
                canvas.drawRoundRect(pillRect, 16f, 16f, pillBgPaint)
                canvas.drawText(timeRemaining, pillRect.centerX(), 174f, pillTextPaint)
            }

            // 4. Six Prayer Times Cards Grid (Y: 215 to 375)
            val prayerKeys = listOf("fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha")
            val prayerNames = listOf("الفجر", "الشروق", "الظهر", "العصر", "المغرب", "العشاء")
            val prayerTimes = listOf(fajr, sunrise, dhuhr, asr, maghrib, isha)

            val marginH = 25f
            val spacing = 10f
            val cardCount = 6
            val totalSpacing = spacing * (cardCount - 1)
            val cardWidth = (width - (marginH * 2) - totalSpacing) / cardCount
            val cardHeight = 160f
            val cardY = 215f

            for (i in 0 until cardCount) {
                // RTL order: Fajr on right (index 0 at highest X)
                val colIndex = (cardCount - 1) - i
                val cardX = marginH + colIndex * (cardWidth + spacing)
                val cardRect = RectF(cardX, cardY, cardX + cardWidth, cardY + cardHeight)

                val key = prayerKeys[i]
                val name = prayerNames[i]
                val time = prayerTimes[i]
                val isActive = key.equals(activeKey, ignoreCase = true)

                if (isActive) {
                    // Active prayer card with glowing emerald/gold design
                    val activeBgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = LinearGradient(
                            cardRect.left, cardRect.top, cardRect.right, cardRect.bottom,
                            intArrayOf(
                                Color.parseColor("#156753"),
                                Color.parseColor("#0D4436")
                            ),
                            null,
                            Shader.TileMode.CLAMP
                        )
                    }
                    canvas.drawRoundRect(cardRect, 18f, 18f, activeBgPaint)

                    val activeBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = Color.parseColor("#FDE68A")
                        style = Paint.Style.STROKE
                        strokeWidth = 2.5f
                    }
                    canvas.drawRoundRect(cardRect, 18f, 18f, activeBorderPaint)

                    // Active Glowing Dot
                    val dotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = Color.parseColor("#FDE68A")
                    }
                    canvas.drawCircle(cardRect.centerX(), cardRect.top + 18f, 4f, dotPaint)

                    val activeNamePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = goldLightColor
                        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                        textSize = 21f
                        textAlign = Paint.Align.CENTER
                    }
                    canvas.drawText(name, cardRect.centerX(), cardRect.top + 58f, activeNamePaint)

                    val activeTimePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = whiteColor
                        typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
                        textSize = 23f
                        textAlign = Paint.Align.CENTER
                    }
                    canvas.drawText(time, cardRect.centerX(), cardRect.top + 104f, activeTimePaint)

                    val activeBadgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = Color.parseColor("#FDE68A")
                        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                        textSize = 14f
                        textAlign = Paint.Align.CENTER
                    }
                    canvas.drawText("الآن / التالية", cardRect.centerX(), cardRect.top + 138f, activeBadgePaint)
                } else {
                    // Inactive regular prayer card
                    val inactiveBgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = Color.parseColor("#082820")
                    }
                    canvas.drawRoundRect(cardRect, 18f, 18f, inactiveBgPaint)

                    val inactiveBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = goldColor
                        style = Paint.Style.STROKE
                        strokeWidth = 1f
                        alpha = 40
                    }
                    canvas.drawRoundRect(cardRect, 18f, 18f, inactiveBorderPaint)

                    val inactiveNamePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = Color.parseColor("#A7F3D0")
                        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                        textSize = 19f
                        textAlign = Paint.Align.CENTER
                    }
                    canvas.drawText(name, cardRect.centerX(), cardRect.top + 56f, inactiveNamePaint)

                    val inactiveTimePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = whiteColor
                        typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
                        textSize = 22f
                        textAlign = Paint.Align.CENTER
                    }
                    canvas.drawText(time, cardRect.centerX(), cardRect.top + 106f, inactiveTimePaint)
                }
            }

            // 5. Bottom Daily Dhikr Ribbon (Y: 390 to 455)
            val dhikrRect = RectF(25f, 390f, (width - 25).toFloat(), 455f)
            val dhikrBgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.parseColor("#051E18")
            }
            canvas.drawRoundRect(dhikrRect, 14f, 14f, dhikrBgPaint)

            val dhikrBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldColor
                style = Paint.Style.STROKE
                strokeWidth = 1f
                alpha = 60
            }
            canvas.drawRoundRect(dhikrRect, 14f, 14f, dhikrBorderPaint)

            val dhikrTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = goldLightColor
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textSize = 18f
                textAlign = Paint.Align.CENTER
            }
            val displayDhikr = if (dailyDhikr.length > 55) {
                dailyDhikr.substring(0, 52) + "..."
            } else {
                dailyDhikr
            }
            canvas.drawText("✨ $displayDhikr", dhikrRect.centerX(), 430f, dhikrTextPaint)

            return bitmap
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
