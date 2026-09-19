import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/dhikr_reminders/domain/dhikr_reminder_item.dart';
import '../../features/prayer_times/domain/adhan_voice.dart';
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
          if (payload.startsWith('adhan:') || payload.startsWith('reminder:')) {
            _setPendingRoute('/prayers');
          } else if (payload.startsWith('dhikr:')) {
            _setPendingRoute('/adhkar');
          } else {
            _setPendingRoute(payload);
          }
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
      } else if (payload.startsWith('dhikr:')) {
        _setPendingRoute('/adhkar');
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
    required AdhanVoice voice,
  }) async {
    if (!isSupported) return;
    try {
      if (prayer.time.isBefore(DateTime.now())) {
        return;
      }

      final bigTextStyle = BigTextStyleInformation(
        'الله أكبر، الله أكبر ۝ حان الآن موعد أذان صلاة ${prayer.name} حسب توقيت $city.\n'
        '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحْمُوداً الَّذِي وَعَدْتَهُ»',
        contentTitle: '🕌 حان موعد أذان ${prayer.name} (${voice.name}) | $formattedTime',
        summaryText: 'ذكرني • مواقيت الصلاة',
      );

      final androidDetails = AndroidNotificationDetails(
        voice.channelId,
        'أذان - ${voice.name}',
        channelDescription: 'تنبيهات الأذان الكاملة بأعلى أولوية وصوت ${voice.name}',
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_stat_zekrni',
        sound: RawResourceAndroidNotificationSound(voice.rawSoundName),
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

      final iosDetails = DarwinNotificationDetails(
        sound: '${voice.rawSoundName}.caf',
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

  /// Periodic Daytime Dhikr Notifications (التذكير بالذكر النبوي والصلاة على النبي ﷺ)
  Future<void> schedulePeriodicDhikrNotifications({
    required PrayerPreferences preferences,
  }) async {
    if (!isSupported) return;
    await cancelDhikrNotifications();
    if (!preferences.dhikrReminderEnabled || preferences.dhikrIntervalMinutes <= 0) {
      return;
    }

    final intervalMinutes = preferences.dhikrIntervalMinutes;
    final now = DateTime.now();
    var reminderId = 5000;
    var dhikrIndex = 0;

    final enabledReminders = defaultDhikrReminders
        .where((r) => preferences.enabledDhikrIds.contains(r.id))
        .toList();
    final itemsToUse =
        enabledReminders.isNotEmpty ? enabledReminders : defaultDhikrReminders;

    // Schedule across next 3 days during active daytime hours (8:00 AM to 10:30 PM)
    for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final startDay = DateTime(date.year, date.month, date.day, 8, 0);
      final endDay = DateTime(date.year, date.month, date.day, 22, 30);

      var scheduledTime = startDay;
      while (scheduledTime.isBefore(endDay)) {
        if (scheduledTime.isAfter(now)) {
          final item = itemsToUse[dhikrIndex % itemsToUse.length];
          dhikrIndex++;

          await _scheduleSingleDhikrNotification(
            id: reminderId++,
            item: item,
            scheduledTime: scheduledTime,
          );

          if (reminderId >= 5200) break;
        }
        scheduledTime = scheduledTime.add(Duration(minutes: intervalMinutes));
      }
      if (reminderId >= 5200) break;
    }
  }

  Future<void> _scheduleSingleDhikrNotification({
    required int id,
    required DhikrReminderItem item,
    required DateTime scheduledTime,
  }) async {
    final bigTextStyle = BigTextStyleInformation(
      '${item.text}\n\n${item.virtue}',
      contentTitle: item.title,
      summaryText: 'ذكرني • تذكير بذكر الله',
    );

    final androidDetails = AndroidNotificationDetails(
      'daily_dhikr_channel_v1',
      'التذكير بذكر الله والصلاة على النبي',
      channelDescription: 'تنبيهات الأذكار العائمة والصلاة على النبي ﷺ أثناء اليوم',
      importance: Importance.max,
      priority: Priority.max,
      icon: 'ic_stat_zekrni',
      playSound: true,
      enableVibration: true,
      color: const Color(0xFF0D9488),
      category: AndroidNotificationCategory.reminder,
      ticker: item.title,
      styleInformation: bigTextStyle,
      actions: const [
        AndroidNotificationAction(
          'open_adhkar',
          '✨ فتح الأذكار',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'dismiss_dhikr',
          'تم الذكر',
          showsUserInterface: false,
          cancelNotification: true,
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
      title: item.title,
      body: item.text,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'dhikr:${item.id}',
    );
  }

  Future<void> cancelDhikrNotifications() async {
    if (!isSupported) return;
    try {
      for (int id = 5000; id < 5250; id++) {
        await _plugin.cancel(id: id);
      }
    } catch (_) {}
  }

  /// Reschedules both Pre-Prayer Reminders, Exact Prayer Time Azans, and Periodic Dhikr
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

        // 1. ALWAYS schedule the exact Azan at prayer.time with selected voice:
        await scheduleExactAdhanNotification(
          id: exactId++,
          prayer: prayer,
          city: preferences.city,
          formattedTime: timeFormat.format(prayer.time),
          overlayOnAdhan: preferences.overlayOnAdhan,
          voice: preferences.selectedVoice,
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

    // 3. Schedule Periodic Daytime Dhikr Reminders:
    await schedulePeriodicDhikrNotifications(preferences: preferences);
  }

  /// Immediate test notification to verify audio, aesthetics, and actions
  Future<void> showTestAdhanNotification({
    required String prayerName,
    required String city,
    AdhanVoice? voice,
  }) async {
    if (!isSupported) return;
    await requestPermissions();

    final activeVoice = voice ?? supportedAdhanVoices.first;
    final nowTime = DateFormat('hh:mm a', 'ar').format(DateTime.now());
    final bigTextStyle = BigTextStyleInformation(
      'الله أكبر، الله أكبر ۝ حان الآن موعد أذان صلاة $prayerName حسب توقيت $city.\n'
      '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحْمُوداً الَّذِي وَعَدْتَهُ»',
      contentTitle: '🕌 تجربة أذان $prayerName (${activeVoice.name}) | $nowTime',
      summaryText: 'ذكرني • تجربة الأذان',
    );

    final androidDetails = AndroidNotificationDetails(
      activeVoice.channelId,
      'أذان - ${activeVoice.name}',
      channelDescription: 'تنبيهات الأذان الكاملة بأعلى أولوية وصوت ${activeVoice.name}',
      importance: Importance.max,
      priority: Priority.max,
      icon: 'ic_stat_zekrni',
      sound: RawResourceAndroidNotificationSound(activeVoice.rawSoundName),
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
      body: 'الله أكبر • تجربة أذان صلاة $prayerName بتوقيت $city (${activeVoice.name})',
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          sound: '${activeVoice.rawSoundName}.caf',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'adhan:test:$prayerName',
    );
  }

  /// Immediate test notification for Dhikr
  Future<void> showTestDhikrNotification({
    DhikrReminderItem? item,
    bool showOverlay = false,
  }) async {
    if (!isSupported) return;
    await requestPermissions();

    final reminder = item ?? defaultDhikrReminders.first;

    if (showOverlay) {
      await AdhanOverlayManager.showDhikrOverlay(
        title: reminder.title,
        text: reminder.text,
        virtue: reminder.virtue,
      );
    }

    final bigTextStyle = BigTextStyleInformation(
      '${reminder.text}\n\n${reminder.virtue}',
      contentTitle: reminder.title,
      summaryText: 'ذكرني • تجربة التذكير بذكر الله',
    );

    final androidDetails = AndroidNotificationDetails(
      'daily_dhikr_channel_v1',
      'التذكير بذكر الله والصلاة على النبي',
      channelDescription: 'تنبيهات الأذكار العائمة والصلاة على النبي ﷺ أثناء اليوم',
      importance: Importance.max,
      priority: Priority.max,
      icon: 'ic_stat_zekrni',
      playSound: true,
      enableVibration: true,
      color: const Color(0xFF0D9488),
      category: AndroidNotificationCategory.reminder,
      ticker: reminder.title,
      styleInformation: bigTextStyle,
      actions: const [
        AndroidNotificationAction(
          'open_adhkar',
          '✨ فتح الأذكار',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'dismiss_dhikr',
          'تم الذكر',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    await _plugin.show(
      id: 4999,
      title: reminder.title,
      body: reminder.text,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'dhikr:${reminder.id}',
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
