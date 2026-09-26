import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/recitations/presentation/widgets/recitation_player_bar.dart';
import '../widgets/fatimid_decorations.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_isTopLevelRoute(location) || location == '/',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && location != '/') {
          context.go('/');
        }
      },
      child: IslamicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: child),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 860),
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
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0A1813).withValues(alpha: 0.96)
                            : Colors.white.withValues(alpha: 0.96),
                        border: Border(
                          top: BorderSide(
                            color: FatimidColors.goldPrimary.withValues(
                              alpha: isDark ? 0.35 : 0.3,
                            ),
                            width: 1.2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          height: 64,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(navItems.length, (i) {
                              final item = navItems[i];
                              final isSelected = i == index;
                              return Expanded(
                                child: InkWell(
                                  onTap: () => context.go(item.route),
                                  splashColor: FatimidColors.goldPrimary.withValues(alpha: 0.12),
                                  highlightColor: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 220),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isDark
                                                  ? FatimidColors.goldPrimary.withValues(alpha: 0.18)
                                                  : FatimidColors.goldPrimary.withValues(alpha: 0.15))
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          border: isSelected
                                              ? Border.all(
                                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
                                                  width: 1,
                                                )
                                              : null,
                                        ),
                                        child: Icon(
                                          isSelected ? item.activeIcon : item.icon,
                                          color: isSelected
                                              ? (isDark
                                                  ? FatimidColors.goldLight
                                                  : const Color(0xFF8B670A))
                                              : (isDark
                                                  ? const Color(0xFF759187)
                                                  : const Color(0xFF6B8279)),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected
                                              ? (isDark ? FatimidColors.goldLight : const Color(0xFF7A5805))
                                              : (isDark ? const Color(0xFF759187) : const Color(0xFF6B8279)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
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
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 240 : 80,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0B1713).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.94),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // App Header with Fatimid gold medallion
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
                    gradient: FatimidColors.goldGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: Image.asset(
                      'assets/branding/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF332000),
                        size: 22,
                      ),
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
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : const Color(0xFF0E2E23),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'الرفيق الإسلامي الفاطمي',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Cairo',
                            color: FatimidColors.goldPrimary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
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
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
          ),
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
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: isSelected ? FatimidColors.goldGradient : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? const Color(0xFF261800)
                                : (isDark ? const Color(0xFF86A398) : const Color(0xFF5E796F)),
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
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? FatimidColors.goldPrimary.withValues(alpha: 0.18)
                                  : FatimidColors.goldPrimary.withValues(alpha: 0.12))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? (isDark ? FatimidColors.goldLight : const Color(0xFF825F05))
                                  : (isDark ? const Color(0xFF86A398) : const Color(0xFF5E796F)),
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? (isDark ? Colors.white : const Color(0xFF103024))
                                      : (isDark ? const Color(0xFF9CB8AE) : const Color(0xFF5E796F)),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: FatimidColors.goldPrimary,
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

          // Developer & Company Link (Maestro Zone)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/company'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? FatimidColors.goldPrimary.withValues(alpha: 0.1)
                          : FatimidColors.goldPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.business_rounded,
                          size: 16,
                          color: FatimidColors.goldPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'المطور: مايسترو زون',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : const Color(0xFF103024),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: FatimidColors.goldPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom dhikr note in Fatimid calligraphy
          if (isExpanded)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12241F) : const Color(0xFFF9F5EA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    '«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      color: FatimidColors.goldPrimary,
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

