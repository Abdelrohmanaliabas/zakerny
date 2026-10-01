import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  test('hijri length of month and days calculation for all 12 months', () {
    final hijri = HijriCalendar();
    for (int month = 1; month <= 12; month++) {
      final days = hijri.getDaysInMonth(1446, month);
      expect(days >= 29 && days <= 30, isTrue);

      final gregFirst = hijri.hijriToGregorian(1446, month, 1);
      expect(gregFirst, isNotNull);

      final gregLast = hijri.hijriToGregorian(1446, month, days);
      expect(gregLast, isNotNull);
    }
  });
}
