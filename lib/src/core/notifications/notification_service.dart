import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/prayer_times/domain/prayer_day.dart';
import '../../features/prayer_times/domain/prayer_preferences.dart';
import '../../features/prayer_times/overlay/adhan_overlay_widget.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (response.actionId == 'stop_adhan') {
    AdhanOverlayManager.closeOverlay();
  }
}

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  String? _pendingRoute;

  bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  String? takePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  Future<void> initialize() async {
    if (!isSupported) return;
    try {
      const android = AndroidInitializationSettings('@drawable/ic_stat_zekrni');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (response) {
          _handleNotificationResponse(response);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null) {
          _setPendingRoute(payload.startsWith('adhan:') ? '/prayers' : payload);
        }
      }
    } catch (_) {}
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.actionId == 'stop_adhan') {
      AdhanOverlayManager.closeOverlay();
      return;
    }
    final payload = response.payload;
    if (payload != null) {
      if (payload.startsWith('adhan:') || payload.startsWith('reminder:')) {
        _setPendingRoute('/prayers');
      } else {
        _setPendingRoute(payload);
      }
    }
  }

  Future<void> requestPermissions() async {
    if (!isSupported) return;
    try {
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
    } catch (_) {}
  }

  /// Exact Prayer Time Azan Notification (حان الآن موعد الأذان)
  Future<void> scheduleExactAdhanNotification({
    required int id,
    required PrayerMoment prayer,
    required String city,
    required String formattedTime,
    required bool overlayOnAdhan,
  }) async {
    if (!isSupported) return;
    try {
      if (prayer.time.isBefore(DateTime.now())) {
        return;
      }

      final bigTextStyle = BigTextStyleInformation(
        'الله أكبر، الله أكبر ۝ حان الآن موعد أذان صلاة ${prayer.name} حسب توقيت $city.\n'
        '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحْمُوداً الَّذِي وَعَدْتَهُ»',
        contentTitle: '🕌 حان موعد أذان ${prayer.name} | $formattedTime',
        summaryText: 'ذكرني • مواقيت الصلاة',
      );

      final androidDetails = AndroidNotificationDetails(
        'prayer_times_adhan_v3',
        'أذان مواقيت الصلاة',
        channelDescription: 'تنبيهات الأذان الكاملة بأعلى أولوية وصوت الأذان',
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_stat_zekrni',
        sound: const RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        color: const Color(0xFF0D9488),
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        ticker: 'حان الآن موعد أذان صلاة ${prayer.name}',
        styleInformation: bigTextStyle,
        actions: const [
          AndroidNotificationAction(
            'stop_adhan',
            '🔇 كتم الأذان',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'open_prayer',
            '🕌 فتح التطبيق',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        sound: 'adhan.caf',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      await _plugin.zonedSchedule(
        id: id,
        title: '🕌 حان موعد أذان ${prayer.name}',
        body: 'الله أكبر • حان الآن موعد صلاة ${prayer.name} بتوقيت $city',
        scheduledDate: tz.TZDateTime.from(prayer.time, tz.local),
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'adhan:${prayer.key}:${prayer.name}',
      );
    } catch (_) {}
  }

  /// Pre-Prayer Reminder Notification (التنبيه قبل الصلاة بالوقت المحدد)
  Future<void> schedulePrePrayerReminderNotification({
    required int id,
    required PrayerMoment prayer,
    required int minutesBefore,
    required String city,
  }) async {
    if (!isSupported || minutesBefore <= 0) return;
    try {
      final scheduled = prayer.time.subtract(Duration(minutes: minutesBefore));
      if (scheduled.isBefore(DateTime.now())) {
        return;
      }

      final bigTextStyle = BigTextStyleInformation(
        'متبقي $minutesBefore دقيقة على موعد أذان صلاة ${prayer.name} بتوقيت $city.\n'
        'استعد الآن للوضوء وإدراك تكبيرة الإحرام.',
        contentTitle: '⏳ اقتربت صلاة ${prayer.name} (باقي $minutesBefore دقيقة)',
        summaryText: 'ذكرني • تذكير قبل الصلاة',
      );

      final androidDetails = AndroidNotificationDetails(
        'prayer_times_reminder_v1',
        'تذكير قبل الأذان',
        channelDescription: 'تنبيهات الاستعداد للصلاة قبل موعد الأذان',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_stat_zekrni',
        playSound: true,
        color: const Color(0xFF0D9488),
        category: AndroidNotificationCategory.reminder,
        ticker: 'اقترب موعد أذان صلاة ${prayer.name}',
        styleInformation: bigTextStyle,
        actions: const [
          AndroidNotificationAction(
            'open_prayer',
            '🕌 فتح التطبيق',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _plugin.zonedSchedule(
        id: id,
        title: '⏳ اقتربت صلاة ${prayer.name}',
        body: 'باقي $minutesBefore دقيقة على موعد صلاة ${prayer.name} • استعد للوضوء',
        scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'reminder:${prayer.key}:${prayer.name}',
      );
    } catch (_) {}
  }

  Future<void> cancelPrayerNotification(int id) async {
    if (!isSupported) return;
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  Future<void> cancelAllPrayerNotifications() async {
    if (!isSupported) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// Reschedules both Pre-Prayer Reminders AND Exact Prayer Time Azans
  Future<void> rescheduleAllPrayerNotifications({
    required List<PrayerDay> days,
    required PrayerPreferences preferences,
  }) async {
    if (!isSupported) return;
    await requestPermissions();
    await cancelAllPrayerNotifications();

    final timeFormat = DateFormat('hh:mm a', 'ar');
    var exactId = 1000;
    var reminderId = 3000;

    for (final day in days) {
      for (final prayer in day.prayers) {
        if (prayer.key == 'sunrise' ||
            preferences.enabledPrayers[prayer.key] != true) {
          continue;
        }

        // 1. ALWAYS schedule the exact Azan at prayer.time:
        await scheduleExactAdhanNotification(
          id: exactId++,
          prayer: prayer,
          city: preferences.city,
          formattedTime: timeFormat.format(prayer.time),
          overlayOnAdhan: preferences.overlayOnAdhan,
        );

        // 2. Schedule Pre-Prayer Reminder if configured:
        if (preferences.reminderMinutes > 0) {
          await schedulePrePrayerReminderNotification(
            id: reminderId++,
            prayer: prayer,
            minutesBefore: preferences.reminderMinutes,
            city: preferences.city,
          );
        }
      }
    }
  }

  /// Immediate test notification to verify audio, aesthetics, and actions
  Future<void> showTestAdhanNotification({
    required String prayerName,
    required String city,
  }) async {
    if (!isSupported) return;
    await requestPermissions();

    final nowTime = DateFormat('hh:mm a', 'ar').format(DateTime.now());
    final bigTextStyle = BigTextStyleInformation(
      'الله أكبر، الله أكبر ۝ حان الآن موعد أذان صلاة $prayerName حسب توقيت $city.\n'
      '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحْمُوداً الَّذِي وَعَدْتَهُ»',
      contentTitle: '🕌 تجربة أذان $prayerName | $nowTime',
      summaryText: 'ذكرني • تجربة الأذان',
    );

    final androidDetails = AndroidNotificationDetails(
      'prayer_times_adhan_v3',
      'أذان مواقيت الصلاة',
      channelDescription: 'تنبيهات الأذان الكاملة بأعلى أولوية وصوت الأذان',
      importance: Importance.max,
      priority: Priority.max,
      icon: 'ic_stat_zekrni',
      sound: const RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      enableVibration: true,
      color: const Color(0xFF0D9488),
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      styleInformation: bigTextStyle,
      actions: const [
        AndroidNotificationAction(
          'stop_adhan',
          '🔇 كتم الأذان',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'open_prayer',
          '🕌 فتح التطبيق',
          showsUserInterface: true,
        ),
      ],
    );

    await _plugin.show(
      id: 999,
      title: '🕌 حان موعد أذان $prayerName',
      body: 'الله أكبر • تجربة أذان صلاة $prayerName بتوقيت $city',
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          sound: 'adhan.caf',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'adhan:test:$prayerName',
    );
  }

  void _setPendingRoute(String? route) {
    if (route == null || route.isEmpty) {
      return;
    }
    _pendingRoute = route;
    notifyListeners();
  }
}
