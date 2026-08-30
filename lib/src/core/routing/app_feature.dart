import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavItem {
  const AppNavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class AppFeature {
  const AppFeature({
    required this.name,
    required this.navItem,
    required this.routes,
  });

  final String name;
  final AppNavItem navItem;
  final List<RouteBase> routes;
}
