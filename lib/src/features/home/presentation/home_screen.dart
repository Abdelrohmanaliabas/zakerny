import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../../hadith/application/hadith_controller.dart';
import '../../hadith/domain/hadith_models.dart';
import '../../prayer_times/application/prayer_controller.dart';
import '../../quran/application/quran_controller.dart';
import '../../recitations/application/recitations_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.prayer,
    required this.quran,
    required this.hadith,
    required this.recitations,
  });

  final PrayerController prayer;
  final QuranController quran;
  final HadithController hadith;
  final RecitationsController recitations;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.prayer.loadPreferences();
    final day = widget.prayer.today(prefs);
    final tomorrow = widget.prayer.tomorrow(prefs);
    final next = day.nextPrayer(DateTime.now(), tomorrow: tomorrow);
    final remaining = next.time.difference(DateTime.now());
    final lastRead = widget.quran.lastRead();
    final downloads = widget.recitations.downloads();
    final timeFormat = DateFormat('hh:mm a', 'ar');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ZekrniHeader(
              title: 'ذكرني',
              subtitle: prefs.city,
              showSearch: false,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. محراب الصلاة القادمة الفاطمي (Fatimid Mihrab Hero Card)
                      _FatimidPrayerMihrab(
                        prayerName: next.name,
                        time: timeFormat.format(next.time),
                        remaining: remaining,
                        onTap: () => context.go('/prayers'),
                      ),
                      const SizedBox(height: 22),

                      // 2. شريط الأقسام السريعة (من أجلك)
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
                            'من أجلك',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F2C22),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'الوصول السريع',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FatimidColors.goldPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.95,
                        children: [
                          _QuickAction(
                            icon: Icons.explore_rounded,
                            label: 'القبلة',
                            badge: 'مباشر',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD97706), Color(0xFFB45309)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/qibla'),
                          ),
                          _QuickAction(
                            icon: Icons.favorite_rounded,
                            label: 'الأذكار',
                            badge: 'ورد',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/adhkar'),
                          ),
                          _QuickAction(
                            icon: Icons.menu_book_rounded,
                            label: 'المصحف',
                            badge: 'كامل',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.go('/quran'),
                          ),
                          _QuickAction(
                            icon: Icons.headphones_rounded,
                            label: 'القراء',
                            badge: 'صوتيات',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.go('/recitations'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // 3. بطاقات متابعة القراءة والأحاديث والتلاوات
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
                            'المتابعة اليومية',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F2C22),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // متابعة المصحف
                      FatimidCard(
                        onTap: () => lastRead == null
                            ? context.go('/quran')
                            : context.push('/quran/surah/${lastRead.surahId}'),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: FatimidColors.goldPrimary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'متابعة القراءة',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: FatimidColors.emeraldPrimary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          lastRead == null ? 'ابدأ الآن' : 'موضع محفوظ',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFF6EE7B7) : FatimidColors.emeraldPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lastRead == null
                                        ? 'اضغط لبدء قراءة المصحف الشريف'
                                        : '${lastRead.surahName}، آية ${lastRead.ayahNumber}',
                                    style: TextStyle(
                                      fontFamily: lastRead == null ? 'Cairo' : 'Amiri',
                                      fontSize: lastRead == null ? 12 : 14,
                                      fontWeight: lastRead == null ? FontWeight.normal : FontWeight.bold,
                                      color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_left_rounded,
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // آخر حديث نبوي
                      FutureBuilder<List<Hadith>>(
                        future: widget.hadith.load(),
                        builder: (context, snapshot) {
                          final items = snapshot.data ?? const [];
                          final lastId = widget.hadith.lastHadithId();
                          final item = items.where((h) => h.id == lastId).firstOrNull ??
                              (items.isEmpty ? null : items.first);
                          return FatimidCard(
                            onTap: () => context.go('/hadith'),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFD97706).withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.format_quote_rounded,
                                    color: Color(0xFFD97706),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text(
                                            'حديث اليوم',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            'سنة نبوية',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item?.title ?? 'أحاديث نبوية شريفة موثقة',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_left_rounded,
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.8),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // التلاوات المحملة
                      FatimidCard(
                        onTap: () => context.go('/recitations'),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.download_done_rounded,
                                color: Color(0xFF7C3AED),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'التلاوات المحملة',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${downloads.length} سورة',
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7C3AED),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    downloads.isEmpty
                                        ? 'حمل السور واستمع إليها بدون إنترنت'
                                        : '${downloads.length} سورة جاهزة للاستماع دون إنترنت',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_left_rounded,
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// محراب الصلاة الفاطمي المذهب (The Fatimid Mihrab Hero Card)
class _FatimidPrayerMihrab extends StatelessWidget {
  const _FatimidPrayerMihrab({
    required this.prayerName,
    required this.time,
    required this.remaining,
    required this.onTap,
  });

  final String prayerName;
  final String time;
  final Duration remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = remaining.isNegative ? 0 : remaining.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: FatimidColors.emeraldGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: FatimidColors.goldPrimary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: FatimidColors.emeraldPrimary.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Fatimid Rosette Fluting (شميسة مضلعة مشعة في الخلفية)
            Positioned(
              right: -30,
              top: -30,
              child: FatimidRosette(
                size: 210,
                color: FatimidColors.goldLight,
                opacity: 0.12,
              ),
            ),

            // Top decorative keel arch border line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: FatimidColors.goldGradient,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Row(
                children: [
                  // Mosque / Mihrab glowing medallion
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: FatimidColors.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: FatimidColors.emeraldDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: FatimidColors.goldLight,
                          size: 28,
                        ),
                      ),
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
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: FatimidColors.goldLight.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'الصلاة القادمة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: FatimidColors.goldLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prayerName,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: FatimidColors.goldLight,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              time,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: FatimidColors.goldLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              totalSeconds <= 0
                                  ? '• حان موعد الأذان'
                                  : '• متبقي $hours س و $minutes د و $seconds ث',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: FatimidColors.goldLight,
                      size: 16,
                    ),
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

/// زر وصول سريع مصمم كفص جوهرة فاطمي (Gemstone Arch Action)
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.badge,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String badge;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? FatimidColors.obsidianCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.3 : 0.22),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF102820),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
