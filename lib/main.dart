import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:timezone/data/latest.dart' as tz_data;
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

  // 1. Parallel lightweight initialization of local storage & Arabic date formatting (~15-25ms)
  final store = SharedPrefsAppLocalStore();
  await Future.wait([
    store.init(),
    initializeDateFormatting('ar', null).catchError((_) {}),
  ]);

  final notifications = NotificationService();

  // 2. Launch UI immediately so the user never sees a stalled white screen!
  runApp(ZekrniApp(store: store, notifications: notifications));

  // 3. Initialize background services asynchronously without blocking the UI
  _initBackgroundServices(store, notifications);
}

void _initBackgroundServices(
  AppLocalStore store,
  NotificationService notifications,
) {
  Future.microtask(() async {
    // A. Timezone configuration (fast with safe timeout & fallback)
    try {
      tz_data.initializeTimeZones();
      await _configureLocalTimezone();
    } catch (_) {}

    // B. Background audio service for recitations
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await JustAudioBackground.init(
          androidNotificationChannelId: 'com.zakerny.app.channel.audio',
          androidNotificationChannelName: 'تلاوات القرآن الكريم',
          androidNotificationOngoing: false,
          androidShowNotificationBadge: true,
        );
      } catch (_) {}
    }

    // C. Voice Dhikr Service
    try {
      VoiceDhikrService.instance.init(store);
    } catch (_) {}

    // D. Local notifications & startup prayer notifications
    try {
      await notifications.initialize();
      await _scheduleStartupPrayerNotifications(store, notifications);
    } catch (_) {}
  });
}

Future<void> _configureLocalTimezone() async {
  try {
    final timezone = await FlutterTimezone.getLocalTimezone()
        .timeout(const Duration(seconds: 2));
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
  } catch (_) {
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.UTC);
      } catch (_) {}
    }
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
    await controller.autoSyncLocationIfPermitted();
    await controller.reschedule(controller.loadPreferences());
  } catch (_) {
    // Notification permissions can be denied; app startup should continue.
  }
}

