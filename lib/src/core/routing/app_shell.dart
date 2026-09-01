import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/islamic_background.dart';
import 'app_feature.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navItems, required this.child});

  final List<AppNavItem> navItems;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFor(location);

    return PopScope(
      canPop: !_isTopLevelRoute(location) || location == '/',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && location != '/') {
          context.go('/');
        }
      },
      child: IslamicBackground(
        child: Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey.shade600,
            onTap: (value) => context.go(navItems[value].route),
            items: navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  int _indexFor(String location) {
    for (var index = 0; index < navItems.length; index++) {
      final route = navItems[index].route;
      if (route == '/' && location == '/') {
        return index;
      }
      if (route != '/' && location.startsWith(route)) {
        return index;
      }
    }
    return 0;
  }

  bool _isTopLevelRoute(String location) {
    return navItems.any((item) => item.route == location);
  }
}
