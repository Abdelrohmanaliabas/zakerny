import 'package:flutter/material.dart';

import '../../../../core/widgets/fatimid_decorations.dart';

/// شريط التحكم العائم بالتمرير التلقائي للقرآن الكريم
class AutoScrollDock extends StatelessWidget {
  const AutoScrollDock({
    super.key,
    required this.isPaused,
    required this.isHoverPaused,
    required this.pauseOnHover,
    required this.speed,
    required this.speedLabel,
    required this.isCollapsed,
    required this.onTogglePause,
    required this.onDecreaseSpeed,
    required this.onIncreaseSpeed,
    required this.onOpenSettings,
    required this.onToggleCollapse,
    required this.onExit,
  });

  final bool isPaused;
  final bool isHoverPaused;
  final bool pauseOnHover;
  final double speed;
  final String speedLabel;
  final bool isCollapsed;
  final VoidCallback onTogglePause;
  final VoidCallback onDecreaseSpeed;
  final VoidCallback onIncreaseSpeed;
  final VoidCallback onOpenSettings;
  final VoidCallback onToggleCollapse;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xEB11231E)
        : Colors.white.withValues(alpha: 0.94);
    final borderColor = isDark
        ? FatimidColors.goldPrimary.withValues(alpha: 0.35)
        : FatimidColors.emeraldPrimary.withValues(alpha: 0.25);

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play / Pause
                  IconButton(
                    iconSize: 22,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    tooltip: isPaused ? 'متابعة التمرير' : 'إيقاف مؤقت',
                    icon: Icon(
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      color: isDark ? FatimidColors.goldLight : colorScheme.primary,
                    ),
                    onPressed: onTogglePause,
                  ),
                  const SizedBox(width: 6),
                  // Speed badge
                  InkWell(
                    onTap: onOpenSettings,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        speedLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? FatimidColors.goldLight : colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Status dot
                  _buildMiniStatusDot(colorScheme),
                  const SizedBox(width: 4),
                  // Expand
                  IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    tooltip: 'توسيع شريط التحكم',
                    icon: const Icon(Icons.keyboard_arrow_up_rounded),
                    onPressed: onToggleCollapse,
                  ),
                  // Exit
                  IconButton(
                    iconSize: 18,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    tooltip: 'إنهاء ملء الشاشة',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onExit,
                  ),
                ],
              ),
            ),
          ),
        );
      }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: borderColor, width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    // Play / Pause prominent action
                    Material(
                      color: isDark ? FatimidColors.goldPrimary : colorScheme.primary,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onTogglePause,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: isDark ? Colors.black87 : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // State Indicator badge
                    _buildStatusBadge(context, isDark),
                    const SizedBox(width: 8),

                    // Speed stepper
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 18,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            tooltip: 'إبطاء السرعة',
                            icon: const Icon(Icons.remove_rounded),
                            onPressed: onDecreaseSpeed,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: onOpenSettings,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    speedLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark
                                          ? FatimidColors.goldLight
                                          : colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    '${speed.round()} px/s',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 18,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            tooltip: 'زيادة السرعة',
                            icon: const Icon(Icons.add_rounded),
                            onPressed: onIncreaseSpeed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Settings modal button
                    IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      tooltip: 'خيارات السرعة والتمرير',
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: onOpenSettings,
                    ),

                    // Collapse button
                    IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      tooltip: 'تصغير الشريط',
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onPressed: onToggleCollapse,
                    ),

                    // Exit Fullscreen button
                    IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      tooltip: 'إنهاء التمرير وملء الشاشة (Esc)',
                      icon: const Icon(Icons.fullscreen_exit_rounded),
                      onPressed: onExit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildMiniStatusDot(ColorScheme colorScheme) {
    if (isPaused) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      );
    }
    if (pauseOnHover && isHoverPaused) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark) {
    if (isPaused) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: isDark ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_outline, size: 15, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              'متوقف مؤقتاً',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (pauseOnHover && isHoverPaused) {
      final amberColor = isDark ? const Color(0xFFFFD54F) : const Color(0xFFE65100);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: amberColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: amberColor.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mouse_rounded, size: 15, color: amberColor),
            const SizedBox(width: 5),
            Text(
              'متوقف للمعاينة (Hover)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: amberColor,
              ),
            ),
          ],
        ),
      );
    }

    final activeColor = isDark ? FatimidColors.emeraldGlow : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_double_arrow_down_rounded, size: 15, color: activeColor),
          const SizedBox(width: 5),
          Text(
            'جارِ التمرير',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// الشريط العلوي العائم في وضع ملء الشاشة
class FullscreenTopBar extends StatelessWidget {
  const FullscreenTopBar({
    super.key,
    required this.surahName,
    required this.isMushafMode,
    required this.isPlayingSurah,
    required this.onToggleMushafMode,
    required this.onTogglePlaySurah,
    required this.onShowFontSize,
    required this.onExitFullscreen,
  });

  final String surahName;
  final bool isMushafMode;
  final bool isPlayingSurah;
  final VoidCallback onToggleMushafMode;
  final VoidCallback onTogglePlaySurah;
  final VoidCallback onShowFontSize;
  final VoidCallback onExitFullscreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xEB0E1F1A)
        : Colors.white.withValues(alpha: 0.92);
    final borderColor = isDark
        ? FatimidColors.goldPrimary.withValues(alpha: 0.25)
        : colorScheme.outlineVariant.withValues(alpha: 0.25);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Exit button
                      IconButton(
                        iconSize: 20,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: const EdgeInsets.all(4),
                        tooltip: 'إنهاء ملء الشاشة (Esc)',
                        icon: const Icon(Icons.fullscreen_exit_rounded),
                        onPressed: onExitFullscreen,
                      ),
                      const SizedBox(width: 6),

                      // Surah title
                      Flexible(
                        child: Text(
                          surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Fullscreen indicator pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ملء الشاشة',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? FatimidColors.goldLight : colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Audio play
                      IconButton(
                        iconSize: 20,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: const EdgeInsets.all(4),
                        tooltip: isPlayingSurah ? 'إيقاف التلاوة' : 'استماع للسورة',
                        icon: Icon(
                          isPlayingSurah
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_outline_rounded,
                          color: isPlayingSurah ? colorScheme.primary : null,
                        ),
                        onPressed: onTogglePlaySurah,
                      ),

                      // Mushaf mode toggle
                      IconButton(
                        iconSize: 20,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: const EdgeInsets.all(4),
                        tooltip: isMushafMode ? 'عرض الآيات كبطاقات' : 'عرض المصحف المتصل',
                        icon: Icon(
                          isMushafMode
                              ? Icons.view_agenda_outlined
                              : Icons.auto_stories_outlined,
                        ),
                        onPressed: onToggleMushafMode,
                      ),

                      // Font size
                      IconButton(
                        iconSize: 20,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: const EdgeInsets.all(4),
                        tooltip: 'حجم الخط',
                        icon: const Icon(Icons.format_size_rounded),
                        onPressed: onShowFontSize,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
}

/// شريحة لاختيار سرعة التمرير الجاهزة
class SpeedPresetChip extends StatelessWidget {
  const SpeedPresetChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg = isDark
        ? FatimidColors.goldPrimary.withValues(alpha: 0.25)
        : colorScheme.primary.withValues(alpha: 0.15);
    final selectedBorder = isDark
        ? FatimidColors.goldPrimary
        : colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? selectedBg
              : (isDark ? Colors.white.withValues(alpha: 0.05) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? selectedBorder
                : (isDark ? Colors.white.withValues(alpha: 0.1) : colorScheme.outlineVariant.withValues(alpha: 0.3)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected
                ? (isDark ? FatimidColors.goldLight : colorScheme.primary)
                : null,
          ),
        ),
      ),
    );
  }
}
