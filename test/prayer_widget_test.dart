import 'package:flutter_test/flutter_test.dart';
import 'package:zakerny/src/features/prayer_times/application/prayer_widget_service.dart';
import 'package:zakerny/src/features/prayer_times/domain/prayer_day.dart';
import 'package:zakerny/src/features/prayer_times/domain/prayer_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PrayerWidgetService safely runs on non-Android or tests without crashing', () async {
    final now = DateTime(2026, 10, 1, 12, 0);
    final day = PrayerDay(
      prayers: [
        PrayerMoment(key: 'fajr', name: 'الفجر', time: DateTime(2026, 10, 1, 4, 30)),
        PrayerMoment(key: 'sunrise', name: 'الشروق', time: DateTime(2026, 10, 1, 5, 55)),
        PrayerMoment(key: 'dhuhr', name: 'الظهر', time: DateTime(2026, 10, 1, 11, 53)),
        PrayerMoment(key: 'asr', name: 'العصر', time: DateTime(2026, 10, 1, 15, 18)),
        PrayerMoment(key: 'maghrib', name: 'المغرب', time: DateTime(2026, 10, 1, 17, 42)),
        PrayerMoment(key: 'isha', name: 'العشاء', time: DateTime(2026, 10, 1, 19, 0)),
      ],
    );

    // Should complete without exception
    await expectLater(
      PrayerWidgetService.updatePrayerWidget(
        day: day,
        preferences: PrayerPreferences.defaults(),
        now: now,
      ),
      completes,
    );
  });
}
