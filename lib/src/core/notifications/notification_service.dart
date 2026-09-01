import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/prayer_times/domain/prayer_day.dart';
import '../../features/prayer_times/domain/prayer_preferences.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  String? _pendingRoute;

  String? takePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@drawable/ic_stat_zekrni');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        _setPendingRoute(response.payload);
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _setPendingRoute(launchDetails?.notificationResponse?.payload);
    }
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required PrayerMoment prayer,
    required int minutesBefore,
  }) async {
    final scheduled = prayer.time.subtract(Duration(minutes: minutesBefore));
    if (scheduled.isBefore(DateTime.now())) {
      return;
    }
    await _plugin.zonedSchedule(
      id: id,
      title: 'ذكرني',
      body: minutesBefore == 0
          ? 'حان وقت صلاة ${prayer.name}'
          : 'باقي $minutesBefore دقيقة على صلاة ${prayer.name}',
      scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_adhan',
          'أذان مواقيت الصلاة',
          channelDescription: 'تنبيهات مواقيت الصلاة بصوت الأذان',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_zekrni',
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(sound: 'adhan.caf'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '/prayers',
    );
  }

  Future<void> cancelPrayerNotification(int id) => _plugin.cancel(id: id);

  Future<void> cancelAllPrayerNotifications() async {
    for (var id = 100; id < 700; id++) {
      await _plugin.cancel(id: id);
    }
  }

  Future<void> rescheduleAllPrayerNotifications({
    required List<PrayerDay> days,
    required PrayerPreferences preferences,
  }) async {
    await requestPermissions();
    await cancelAllPrayerNotifications();
    var id = 100;
    for (final day in days) {
      for (final prayer in day.prayers) {
        if (prayer.key == 'sunrise' ||
            preferences.enabledPrayers[prayer.key] != true) {
          continue;
        }
        await schedulePrayerNotification(
          id: id++,
          prayer: prayer,
          minutesBefore: preferences.reminderMinutes,
        );
      }
    }
  }

  void _setPendingRoute(String? route) {
    if (route == null || route.isEmpty) {
      return;
    }
    _pendingRoute = route;
    notifyListeners();
  }
}
