import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/notifications/notification_service.dart';
import 'core/routing/app_router.dart';
import 'core/storage/app_local_store.dart';
import 'core/theme/app_theme.dart';

class ZekrniApp extends StatelessWidget {
  const ZekrniApp({
    super.key,
    required this.store,
    required this.notifications,
  });

  final AppLocalStore store;
  final NotificationService notifications;

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(store: store, notifications: notifications);

    return MaterialApp.router(
      title: 'ذكرني',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
