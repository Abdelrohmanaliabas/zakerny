import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/recitations/presentation/widgets/recitation_player_bar.dart';
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
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;
    final isExpandedSidebar = width >= 1024;

    return PopScope(
      canPop: !_isTopLevelRoute(location) || location == '/',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && location != '/') {
          context.go('/');
        }
      },
      child: IslamicBackground(
        child: Scaffold(
          body: isDesktop
              ? Row(
                  children: [
                    _DesktopSidebar(
                      navItems: navItems,
                      selectedIndex: index,
                      isExpanded: isExpandedSidebar,
                      onTap: (targetIndex) =>
                          context.go(navItems[targetIndex].route),
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: child),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 820),
                              child: const RecitationPlayerBar(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : child,
          bottomNavigationBar: isDesktop
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const RecitationPlayerBar(),
                    BottomNavigationBar(
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
                  ],
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

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.isExpanded,
    required this.onTap,
  });

  final List<AppNavItem> navItems;
  final int selectedIndex;
  final bool isExpanded;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 240 : 80,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withValues(alpha: 0.94)
            : colorScheme.surface.withValues(alpha: 0.90),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // App Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 8,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/branding/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.menu_book_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ذكرني',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'رفيق المسلم اليومي',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 12),

          // Navigation items list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 12 : 8,
                vertical: 4,
              ),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = index == selectedIndex;

                if (!isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Tooltip(
                      message: item.label,
                      preferBelow: false,
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(12),
                      hoverColor: colorScheme.primary.withValues(alpha: 0.08),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom dhikr / quote note
          if (isExpanded)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
