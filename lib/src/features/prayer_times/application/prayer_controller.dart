import '../../../core/notifications/notification_service.dart';
import '../data/prayer_repository.dart';
import '../domain/prayer_day.dart';
import '../domain/prayer_preferences.dart';

class PrayerController {
  PrayerController(this.repository, this.notifications);

  final PrayerRepository repository;
  final NotificationService notifications;

  PrayerPreferences loadPreferences() => repository.getPreferences();

  PrayerDay today(PrayerPreferences prefs) =>
      repository.timesFor(DateTime.now(), prefs);

  Future<PrayerPreferences> save(PrayerPreferences prefs) async {
    await repository.savePreferences(prefs);
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

  Future<void> _reschedule(PrayerPreferences prefs) {
    final today = DateTime.now();
    final days = List.generate(
      7,
      (i) => repository.timesFor(today.add(Duration(days: i)), prefs),
    );
    return notifications.rescheduleAllPrayerNotifications(
      days: days,
      preferences: prefs,
    );
  }
}
