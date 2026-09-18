import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ZekrniHeader extends StatelessWidget {
  const ZekrniHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showSearch = false,
    this.onSearchChanged,
    this.trailing,
    this.onTrailingPressed,
  });

  final String title;
  final String? subtitle;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final Widget? trailing;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF101F1A).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.primary.withValues(alpha: 0.16),
                child: Icon(Icons.auto_stories, color: color.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(color: color.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTrailingPressed != null)
                IconButton.filledTonal(
                  onPressed: onTrailingPressed,
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'خيارات',
                )
              else
                _buildDefaultMenu(context, color, isDark),
            ],
          ),
          if (showSearch) ...[
            const SizedBox(height: 16),
            TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'بحث...',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultMenu(BuildContext context, ColorScheme color, bool isDark) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: color.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          elevation: 8,
          color: isDark ? const Color(0xFF162A24) : Colors.white,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'القائمة السريعة',
        position: PopupMenuPosition.under,
        onSelected: (route) {
          if (route == '/settings' ||
              route == '/qibla' ||
              route == '/adhkar' ||
              route == '/quran/bookmarks') {
            context.push(route);
          } else {
            context.go(route);
          }
        },
        itemBuilder: (context) => [
          _buildPopupItem(
            value: '/settings',
            icon: Icons.settings_rounded,
            title: 'الإعدادات والأذان',
            color: color.primary,
          ),
          _buildPopupItem(
            value: '/qibla',
            icon: Icons.explore_rounded,
            title: 'اتجاه القبلة',
            color: const Color(0xFFD4AF37),
          ),
          _buildPopupItem(
            value: '/adhkar',
            icon: Icons.favorite_rounded,
            title: 'الأذكار والسبحة',
            color: const Color(0xFFE11D48),
          ),
          _buildPopupItem(
            value: '/quran/bookmarks',
            icon: Icons.bookmark_rounded,
            title: 'العلامات المرجعية للمصحف',
            color: const Color(0xFF2563EB),
          ),
          const PopupMenuDivider(),
          _buildPopupItem(
            value: '/prayers',
            icon: Icons.access_time_filled_rounded,
            title: 'مواقيت الصلاة',
            color: color.primary,
          ),
          _buildPopupItem(
            value: '/quran',
            icon: Icons.menu_book_rounded,
            title: 'المصحف الشريف',
            color: const Color(0xFF059669),
          ),
          _buildPopupItem(
            value: '/recitations',
            icon: Icons.headphones_rounded,
            title: 'تلاوات القراء',
            color: const Color(0xFF7C3AED),
          ),
          _buildPopupItem(
            value: '/hadith',
            icon: Icons.format_quote_rounded,
            title: 'الأحاديث النبوية',
            color: const Color(0xFFD97706),
          ),
          const PopupMenuDivider(),
          _buildPopupItem(
            value: '/',
            icon: Icons.home_rounded,
            title: 'الصفحة الرئيسية',
            color: color.primary,
          ),
        ],
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.tune_rounded,
            color: color.onSecondaryContainer,
            size: 20,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem({
    required String value,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
