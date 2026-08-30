import 'package:go_router/go_router.dart';

import '../notifications/notification_service.dart';
import '../storage/app_local_store.dart';
import 'app_shell.dart';
import 'feature_registry.dart';

GoRouter buildRouter({
  required AppLocalStore store,
  required NotificationService notifications,
}) {
  final features = buildFeatureRegistry(
    store: store,
    notifications: notifications,
  );
  final navItems = features.map((feature) => feature.navItem).toList();

  return GoRouter(
    refreshListenable: notifications,
    redirect: (context, state) {
      final payloadRoute = notifications.takePendingRoute();
      if (payloadRoute == null || payloadRoute == state.uri.path) {
        return null;
      }
      return payloadRoute;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(navItems: navItems, child: child),
        routes: features.expand((feature) => feature.routes).toList(),
      ),
    ],
  );
}
