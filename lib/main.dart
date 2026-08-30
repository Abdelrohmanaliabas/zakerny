import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'src/app.dart';
import 'src/core/notifications/notification_service.dart';
import 'src/core/storage/app_local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  tz.initializeTimeZones();

  final store = SharedPrefsAppLocalStore();
  await store.init();

  final notifications = NotificationService();
  await notifications.initialize();

  runApp(ZekrniApp(store: store, notifications: notifications));
}
