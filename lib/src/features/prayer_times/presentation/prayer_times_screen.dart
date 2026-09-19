import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/prayer_controller.dart';
import '../domain/prayer_day.dart';
import '../domain/prayer_preferences.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key, required this.controller});

  final PrayerController controller;

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late PrayerPreferences _prefs;
  late Timer _timer;
  final _timeFormat = DateFormat('hh:mm a', 'ar');
  String? _selectedPrayerKey;

  @override
  void initState() {
    super.initState();
    _prefs = widget.controller.loadPreferences();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.controller.today(_prefs);
    final tomorrow = widget.controller.tomorrow(_prefs);
    final next = day.nextPrayer(DateTime.now(), tomorrow: tomorrow);
    final activeKey = _selectedPrayerKey ?? next.key;
    final activePrayer = day.prayers.firstWhere(
      (p) => p.key == activeKey,
      orElse: () => next,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ZekrniHeader(title: 'مواقيت الصلاة', subtitle: _prefs.city),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // البطاقة الرئيسية للصلاة القادمة أو المختارة
                  _FatimidNextPrayerCard(
                    prayer: activePrayer,
                    isNext: activePrayer.key == next.key,
                    nextTime: next.key == activePrayer.key ? next.time : activePrayer.time,
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: FatimidColors.goldGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مواقيت اليوم',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F2C22),
                        ),
                      ),
                      const Spacer(),
                      if (_selectedPrayerKey != null && _selectedPrayerKey != next.key)
                        TextButton.icon(
                          onPressed: () => setState(() => _selectedPrayerKey = null),
                          icon: const Icon(Icons.my_location_rounded, size: 14),
                          label: const Text('الصلاة القادمة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: FatimidColors.goldPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // أشرطة المواقيت الأفقية القابلة للنقر
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: day.prayers.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final prayer = day.prayers[index];
                        return _PrayerChip(
                          prayer: prayer,
                          selected: prayer.key == activeKey,
                          isNext: prayer.key == next.key,
                          time: _timeFormat.format(prayer.time),
                          onTap: () => setState(() => _selectedPrayerKey = prayer.key),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // بطاقات الصلوات اليومية المفصلة القابلة للنقر
                  ...day.prayers.map(
                    (prayer) {
                      final isSelected = prayer.key == activeKey;
                      final isNext = prayer.key == next.key;
                      final isSunrise = prayer.key == 'sunrise';
                      final isEnabled = _prefs.enabledPrayers[prayer.key] == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected ? FatimidColors.emeraldGradient : null,
                          color: isSelected
                              ? null
                              : (isDark ? FatimidColors.obsidianCard : Colors.white),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? FatimidColors.goldPrimary
                                : (isNext
                                    ? FatimidColors.goldPrimary.withValues(alpha: 0.6)
                                    : FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2)),
                            width: isSelected ? 1.5 : (isNext ? 1.2 : 1.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? FatimidColors.emeraldPrimary.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: isSelected ? 14 : 8,
                              offset: Offset(0, isSelected ? 4 : 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          onTap: () => setState(() => _selectedPrayerKey = prayer.key),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: isSelected ? FatimidColors.goldGradient : null,
                              color: isSelected
                                  ? null
                                  : FatimidColors.goldPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSunrise
                                  ? Icons.wb_sunny_rounded
                                  : (isNext ? Icons.notifications_active_rounded : Icons.access_time_rounded),
                              color: isSelected
                                  ? const Color(0xFF332000)
                                  : FatimidColors.goldPrimary,
                              size: 22,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                prayer.name,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : const Color(0xFF102A21)),
                                ),
                              ),
                              if (isNext) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: FatimidColors.goldPrimary.withValues(alpha: isSelected ? 0.25 : 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'القادمة',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? FatimidColors.goldLight : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            isSunrise
                                ? 'وقت الشروق'
                                : (isEnabled ? 'التنبيه والأذان مفعل' : 'التنبيه متوقف'),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : (isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F)),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : FatimidColors.goldPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.4)
                                    : FatimidColors.goldPrimary.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              _timeFormat.format(prayer.time),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isSelected
                                    ? FatimidColors.goldLight
                                    : (isDark ? FatimidColors.goldLight : const Color(0xFF7A5805)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FatimidNextPrayerCard extends StatelessWidget {
  const _FatimidNextPrayerCard({
    required this.prayer,
    required this.isNext,
    required this.nextTime,
  });

  final PrayerMoment prayer;
  final bool isNext;
  final DateTime nextTime;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remaining = nextTime.difference(now);
    final isPast = !isNext && prayer.time.isBefore(now);
    final totalSeconds = remaining.isNegative ? 0 : remaining.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final badgeText = isNext
        ? 'الصلاة القادمة'
        : (isPast ? 'صلاة مضت' : 'صلاة مختارة');

    final countdownText = isNext
        ? (totalSeconds <= 0
            ? 'حان موعد الأذان الآن'
            : 'متبقي $hours ساعة و $minutes دقيقة و $seconds ثانية حتى الأذان')
        : (isPast
            ? 'تم أداء الصلاة لهذا اليوم'
            : 'متبقي $hours ساعة و $minutes دقيقة و $seconds ثانية');

    return Container(
      decoration: BoxDecoration(
        gradient: FatimidColors.emeraldGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: 0.5),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: FatimidColors.emeraldPrimary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: FatimidRosette(
              size: 180,
              color: FatimidColors.goldLight,
              opacity: 0.12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: FatimidColors.goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Color(0xFF332000),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: FatimidColors.goldLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prayer.name,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        countdownText,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerChip extends StatelessWidget {
  const _PrayerChip({
    required this.prayer,
    required this.selected,
    required this.isNext,
    required this.time,
    required this.onTap,
  });

  final PrayerMoment prayer;
  final bool selected;
  final bool isNext;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? FatimidColors.goldGradient : null,
          color: selected
              ? null
              : (isDark ? FatimidColors.obsidianCard : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? FatimidColors.goldLight
                : (isNext
                    ? FatimidColors.goldPrimary.withValues(alpha: 0.6)
                    : FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.25 : 0.2)),
            width: selected ? 1.5 : (isNext ? 1.2 : 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? FatimidColors.goldPrimary.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: selected ? 8 : 4,
              offset: Offset(0, selected ? 3 : 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isNext && !selected) ...[
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD97706),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                Text(
                  prayer.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: selected
                        ? const Color(0xFF332000)
                        : (isDark ? Colors.white : const Color(0xFF102820)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? const Color(0xFF4A3405)
                    : (isDark ? const Color(0xFFA5C4B8) : const Color(0xFF5B7A6F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
