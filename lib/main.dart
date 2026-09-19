import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'src/app.dart';
import 'src/core/notifications/notification_service.dart';
import 'src/core/storage/app_local_store.dart';
import 'src/features/dhikr_reminders/application/voice_dhikr_service.dart';
import 'src/features/prayer_times/application/prayer_controller.dart';
import 'src/features/prayer_times/data/prayer_repository.dart';
import 'src/features/prayer_times/overlay/adhan_overlay_widget.dart';

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdhanOverlayWidget(),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.example.zakerny.channel.audio',
        androidNotificationChannelName: 'تلاوات القرآن الكريم',
        androidNotificationOngoing: false,
        androidShowNotificationBadge: true,
      );
    } catch (_) {}
  }
  await initializeDateFormatting('ar');
  tz_data.initializeTimeZones();
  await _configureLocalTimezone();

  final store = SharedPrefsAppLocalStore();
  await store.init();

  VoiceDhikrService.instance.init(store);

  final notifications = NotificationService();
  await notifications.initialize();
  await _scheduleStartupPrayerNotifications(store, notifications);

  runApp(ZekrniApp(store: store, notifications: notifications));
}

Future<void> _configureLocalTimezone() async {
  try {
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
  }
}

Future<void> _scheduleStartupPrayerNotifications(
  AppLocalStore store,
  NotificationService notifications,
) async {
  if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
    return;
  }
  try {
    final controller = PrayerController(PrayerRepository(store), notifications);
    await controller.reschedule(controller.loadPreferences());
  } catch (_) {
    // Notification permissions can be denied; app startup should continue.
  }
}
