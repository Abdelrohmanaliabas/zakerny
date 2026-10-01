import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../domain/prayer_day.dart';
import '../domain/prayer_preferences.dart';

class PrayerWidgetService {
  static const MethodChannel _channel =
      MethodChannel('com.zakerny.app/prayer_widget');

  /// Updates the Android Home Screen Widget with current prayer times.
  static Future<void> updatePrayerWidget({
    required PrayerDay day,
    required PrayerPreferences preferences,
    PrayerDay? tomorrow,
    DateTime? now,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final currentNow = now ?? DateTime.now();
      final nextPrayer = day.nextPrayer(currentNow, tomorrow: tomorrow);
      final timeFormatter = DateFormat('hh:mm a', 'ar');
      final digitalTimeFormatter = DateFormat('hh:mm', 'en');
      final gregDateFormatter = DateFormat('dd MMM yyyy', 'en');

      PrayerMoment? findPrayer(String key) {
        try {
          return day.prayers.firstWhere((p) => p.key == key);
        } catch (_) {
          return null;
        }
      }

      final fajr = findPrayer('fajr');
      final sunrise = findPrayer('sunrise');
      final dhuhr = findPrayer('dhuhr');
      final asr = findPrayer('asr');
      final maghrib = findPrayer('maghrib');
      final isha = findPrayer('isha');

      HijriCalendar.setLocal('ar');
      final hijriNow = HijriCalendar.fromDate(currentNow);
      final hijriStr = '${hijriNow.hDay} ${hijriNow.longMonthName} ${hijriNow.hYear}';
      final gregStr = gregDateFormatter.format(currentNow).toUpperCase();

      final data = <String, String>{
        'city': preferences.city,
        'next_prayer_name': nextPrayer.name,
        'next_prayer_time': timeFormatter.format(nextPrayer.time),
        'active_prayer_key': nextPrayer.key,
        'current_time': digitalTimeFormatter.format(currentNow),
        'hijri_date': hijriStr,
        'greg_date': gregStr,
        'temp': '22°C',
        'iqamah': '21°F',
        'fajr': fajr != null ? digitalTimeFormatter.format(fajr.time) : '04:22',
        'sunrise': sunrise != null ? digitalTimeFormatter.format(sunrise.time) : '05:39',
        'dhuhr': dhuhr != null ? digitalTimeFormatter.format(dhuhr.time) : '11:49',
        'asr': asr != null ? digitalTimeFormatter.format(asr.time) : '03:16',
        'maghrib': maghrib != null ? digitalTimeFormatter.format(maghrib.time) : '05:57',
        'isha': isha != null ? digitalTimeFormatter.format(isha.time) : '07:27',
      };

      await _channel.invokeMethod('updateWidget', data);
    } catch (_) {}
  }
}
