import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/notifications/notification_service.dart';
import 'core/routing/app_router.dart';
import 'core/storage/app_local_store.dart';
import 'core/theme/app_theme.dart';
import 'features/prayer_times/application/prayer_widget_service.dart';

class ZekrniApp extends StatefulWidget {
  const ZekrniApp({
    super.key,
    required this.store,
    required this.notifications,
  });

  final AppLocalStore store;
  final NotificationService notifications;

  @override
  State<ZekrniApp> createState() => _ZekrniAppState();
}

class _ZekrniAppState extends State<ZekrniApp> {
  late ThemeMode _themeMode;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeMode = _readThemeMode();
    _router = buildRouter(
      store: widget.store,
      notifications: widget.notifications,
      onThemeModeChanged: _setThemeMode,
    );

    // Navigate to prayer clock if app was launched or opened from widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrayerWidgetService.getInitialRoute().then((route) {
        if (route != null && mounted) {
          _router.push(route);
        }
      });
      PrayerWidgetService.listenForDeepLinks((route) {
        if (mounted) {
          _router.push(route);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  ThemeMode _readThemeMode() {
    return switch (widget.store.getString('app_theme_mode')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await widget.store.setString('app_theme_mode', mode.name);
    if (mounted) {
      setState(() => _themeMode = mode);
    }
  }
}
