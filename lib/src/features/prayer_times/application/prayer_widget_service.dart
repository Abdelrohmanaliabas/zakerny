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
        'fajr': fajr != null ? timeFormatter.format(fajr.time) : '٠٥:٢٤ ص',
        'sunrise': sunrise != null ? timeFormatter.format(sunrise.time) : '٠٦:٥١ ص',
        'dhuhr': dhuhr != null ? timeFormatter.format(dhuhr.time) : '١٢:٤٩ م',
        'asr': asr != null ? timeFormatter.format(asr.time) : '٠٤:١٠ م',
        'maghrib': maghrib != null ? timeFormatter.format(maghrib.time) : '٠٦:٤٣ م',
        'isha': isha != null ? timeFormatter.format(isha.time) : '٠٨:٠١ م',
      };

      await _channel.invokeMethod('updateWidget', data);
    } catch (_) {}
  }
}
