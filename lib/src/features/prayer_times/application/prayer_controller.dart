import '../../../core/notifications/notification_service.dart';
import '../../dhikr_reminders/application/voice_dhikr_service.dart';
import '../data/prayer_repository.dart';
import '../domain/prayer_day.dart';
import '../domain/prayer_preferences.dart';
import 'prayer_widget_service.dart';

class PrayerController {
  PrayerController(this.repository, this.notifications);

  final PrayerRepository repository;
  final NotificationService notifications;

  PrayerPreferences loadPreferences() => repository.getPreferences();

  PrayerDay today(PrayerPreferences prefs) =>
      repository.timesFor(DateTime.now(), prefs);

  PrayerDay tomorrow(PrayerPreferences prefs) =>
      repository.timesFor(DateTime.now().add(const Duration(days: 1)), prefs);

  Future<PrayerPreferences> save(PrayerPreferences prefs) async {
    await repository.savePreferences(prefs);
    VoiceDhikrService.instance.updatePreferences(prefs);
    await _reschedule(prefs);
    return prefs;
  }

  Future<PrayerPreferences> useCurrentLocation(
    PrayerPreferences current,
  ) async {
    final next = await repository.useCurrentLocation(current);
    return save(next);
  }

  Future<void> reschedule(PrayerPreferences prefs) => _reschedule(prefs);

  Future<void> updateWidget(PrayerPreferences prefs) async {
    final now = DateTime.now();
    final todayDay = today(prefs);
    final tomorrowDay = tomorrow(prefs);
    await PrayerWidgetService.updatePrayerWidget(
      day: todayDay,
      preferences: prefs,
      tomorrow: tomorrowDay,
      now: now,
    );
  }

  Future<void> _reschedule(PrayerPreferences prefs) async {
    final today = DateTime.now();
    final days = List.generate(
      7,
      (i) => repository.timesFor(today.add(Duration(days: i)), prefs),
    );
    if (days.isNotEmpty) {
      final tomorrow = days.length > 1 ? days[1] : null;
      await PrayerWidgetService.updatePrayerWidget(
        day: days.first,
        preferences: prefs,
        tomorrow: tomorrow,
      );
    }
    await notifications.rescheduleAllPrayerNotifications(
      days: days,
      preferences: prefs,
    );
  }
}
