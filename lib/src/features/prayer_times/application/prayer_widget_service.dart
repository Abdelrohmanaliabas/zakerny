import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
      final shortTimeFormatter = DateFormat('h:mm', 'ar');

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

      final data = <String, String>{
        'city': preferences.city,
        'next_prayer_name': nextPrayer.name,
        'next_prayer_time': timeFormatter.format(nextPrayer.time),
        'active_prayer_key': nextPrayer.key,
        'fajr': fajr != null ? shortTimeFormatter.format(fajr.time) : '04:30',
        'sunrise': sunrise != null ? shortTimeFormatter.format(sunrise.time) : '05:55',
        'dhuhr': dhuhr != null ? shortTimeFormatter.format(dhuhr.time) : '11:53',
        'asr': asr != null ? shortTimeFormatter.format(asr.time) : '03:18',
        'maghrib': maghrib != null ? shortTimeFormatter.format(maghrib.time) : '05:42',
        'isha': isha != null ? shortTimeFormatter.format(isha.time) : '07:00',
      };

      await _channel.invokeMethod('updateWidget', data);
    } catch (_) {}
  }
}
