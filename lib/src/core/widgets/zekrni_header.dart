import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'fatimid_decorations.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0D1C17).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        border: Border(
          bottom: BorderSide(
            color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.3),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Fatimid Golden Rosette Avatar
              Container(
                width: 46,
                height: 46,
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
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A1813) : Colors.white,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.auto_stories,
                      color: isDark ? FatimidColors.goldLight : FatimidColors.emeraldPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        color: isDark ? Colors.white : const Color(0xFF0F2B22),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: FatimidColors.goldPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFA5C4B8)
                                  : const Color(0xFF5B7A6F),
                            ),
                          ),
                        ],
                      ),
                    ],
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
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChanged,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: FatimidColors.goldPrimary,
                    size: 20,
                  ),
                  hintText: 'ابحث في السور، الأذكار، الأحاديث...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: color.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  fillColor: isDark ? const Color(0xFF132720) : const Color(0xFFF9F6EE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: FatimidColors.goldPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
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
              color: FatimidColors.goldPrimary.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          elevation: 12,
          color: isDark ? const Color(0xFF11231E) : Colors.white,
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
            color: FatimidColors.goldPrimary,
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
            color: FatimidColors.emeraldLight,
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
            color: FatimidColors.goldPrimary,
          ),
        ],
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: FatimidColors.goldGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: FatimidColors.goldPrimary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Color(0xFF332000),
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
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
