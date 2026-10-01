import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/arabic_text_utils.dart';

import '../../../core/widgets/fatimid_decorations.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../../calendar/domain/calendar_models.dart';
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
  int _tasbeehCount = 0;
  final int _tasbeehTarget = 33;
  int _selectedDhikrIndex = 0;
  static const List<String> _dhikrList = [
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
  ];

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

                      // بطاقة سُنّة الصيام والتقويم الإسلامي
                      _SunnahFastingBanner(isDark: isDark),

                      // بطاقة ساعة الحرمين الرقمية الفاخرة
                      _AlFajiaClockHeroCard(
                        city: prefs.city,
                        isDark: isDark,
                        onTap: () => context.push('/prayer-clock'),
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
                          _QuickAction(
                            icon: Icons.calendar_month_rounded,
                            label: 'التقويم',
                            badge: 'هجري/ميلادي',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/calendar'),
                          ),
                          _QuickAction(
                            icon: Icons.event_available_rounded,
                            label: 'المناسبات',
                            badge: 'إجازات',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/occasions'),
                          ),
                          _QuickAction(
                            icon: Icons.access_alarm_rounded,
                            label: 'ساعة الحرمين',
                            badge: 'رقمية',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD97706), Color(0xFF92400E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/prayer-clock'),
                          ),
                          _QuickAction(
                            icon: Icons.fingerprint_rounded,
                            label: 'السبحة',
                            badge: 'تسبيح',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/adhkar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // الأدوات والمحاسبة الإسلامية (منظم الختمات، سجل العبادات، صانع البطاقات)
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
                            'أدوات ومحاسبة المسلم',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F2C22),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'جديد ✨',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: FatimidColors.goldPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 1. منظم ومتابع ختمات القرآن الكريم
                      FatimidCard(
                        onTap: () => context.push('/khatmah'),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF059669), Color(0xFF047857)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
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
                                        'منظم ومتابع ختمات القرآن',
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
                                          'خطة الختمة',
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
                                    'تحديد هدف الختمة وحساب الورد بعد كل صلاة وتتبع الإنجاز',
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
                      ),
                      const SizedBox(height: 10),

                      // 2. سجل المحاسبة والعبادات اليومية
                      FatimidCard(
                        onTap: () => context.push('/ibadah-tracker'),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.checklist_rtl_rounded,
                                color: Colors.white,
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
                                        'سجل المحاسبة والعبادات اليومية',
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
                                          color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'محاسبة النفس',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0D9488),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'متابعة الصلوات في وقتها والسنن والأذكار مع إحصائيات أسبوعية',
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
                      ),
                      const SizedBox(height: 10),

                      // 3. صانع بطاقات الآيات والأحاديث
                      FatimidCard(
                        onTap: () => context.push('/card-designer'),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD97706), Color(0xFFB45309)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: FatimidColors.goldPrimary.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.palette_rounded,
                                color: Colors.white,
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
                                        'صانع بطاقات الآيات والأحاديث',
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
                                          color: const Color(0xFFD97706).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'مشاركة وتصميم',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD97706),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'تصميم بطاقات فاخرة بخلفيات فاطمية مذهبة ومشاركتها فوراً',
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
                      ),
                      const SizedBox(height: 22),

                      // 4. بطاقات متابعة القراءة والأحاديث والتلاوات
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
                      const SizedBox(height: 22),

                      // 4. الذكر والتسبيح السريع
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
                            'الذكر والتسبيح السريع',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F2C22),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _QuickHomeTasbeeh(
                        count: _tasbeehCount,
                        target: _tasbeehTarget,
                        selectedPhrase: _dhikrList[_selectedDhikrIndex],
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            if (_tasbeehCount < _tasbeehTarget) {
                              _tasbeehCount++;
                            } else {
                              HapticFeedback.mediumImpact();
                              _tasbeehCount = 1;
                              _selectedDhikrIndex = (_selectedDhikrIndex + 1) % _dhikrList.length;
                            }
                          });
                        },
                        onReset: () {
                          HapticFeedback.selectionClick();
                          setState(() => _tasbeehCount = 0);
                        },
                        onSelectNextPhrase: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedDhikrIndex = (_selectedDhikrIndex + 1) % _dhikrList.length;
                            _tasbeehCount = 0;
                          });
                        },
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

    final hoursAr = ArabicTextUtils.toArabicDigits(hours);
    final minutesAr = ArabicTextUtils.toArabicDigits(minutes);
    final secondsAr = ArabicTextUtils.toArabicDigits(seconds);

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
                            Expanded(
                              child: Text(
                                totalSeconds <= 0
                                    ? '• حان موعد الأذان'
                                    : (hours > 0
                                        ? '• متبقي $hoursAr س و $minutesAr د و $secondsAr ث'
                                        : '• متبقي $minutesAr د و $secondsAr ث'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
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

/// بطاقة تذكير صيام السُّنّة والأيام البيض والمناسبات الإسلامية
class _SunnahFastingBanner extends StatelessWidget {
  const _SunnahFastingBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    final weekday = now.weekday;
    final hour = now.hour;

    String title;
    String subtitle;
    String badge = 'سُنّة نبوية';
    IconData icon = Icons.nights_stay_rounded;

    if (weekday == DateTime.monday) {
      title = 'اليوم الإثنين • سُنّة الصيام';
      subtitle = 'تقبّل الله صيامكم وطاعتكم • موعد الإفطار مع أذان المغرب';
      badge = 'صيام اليوم';
      icon = Icons.wb_sunny_rounded;
    } else if (weekday == DateTime.thursday) {
      title = 'اليوم الخميس • سُنّة الصيام';
      subtitle = 'تقبّل الله صيامكم وطاعتكم • موعد الإفطار مع أذان المغرب';
      badge = 'صيام اليوم';
      icon = Icons.wb_sunny_rounded;
    } else if (weekday == DateTime.sunday && hour >= 16) {
      title = 'تذكير سُنّة الصيام: غداً الإثنين 🌙';
      subtitle = '«تُعرض الأعمال يوم الإثنين والخميس فأحب أن يُعرض عملي وأنا صائم»';
      badge = 'صيام الغد';
    } else if (weekday == DateTime.wednesday && hour >= 16) {
      title = 'تذكير سُنّة الصيام: غداً الخميس 🌙';
      subtitle = '«تُعرض الأعمال يوم الإثنين والخميس فأحب أن يُعرض عملي وأنا صائم»';
      badge = 'صيام الغد';
    } else if (CalendarUtils.isWhiteDay(hijri.hDay)) {
      title = 'صيام الأيام البيض لشهر ${hijri.longMonthName}';
      subtitle = 'اليوم ${hijri.hDay} من الأيام البيض • صيام ثلاثة أيام كصيام الدهر';
      badge = 'الأيام البيض';
      icon = Icons.brightness_2_rounded;
    } else {
      final currentEvent = CalendarUtils.getEventForHijri(hijri.hMonth, hijri.hDay);
      if (currentEvent != null) {
        title = currentEvent.title;
        subtitle = currentEvent.description;
        badge = currentEvent.isHoliday ? 'إجازة رسمية' : 'مناسبة إسلامية';
        icon = Icons.stars_rounded;
      } else {
        title = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';
        subtitle = '«أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ» • تقويم ومناسبات اليوم';
        badge = 'التقويم الهجري';
        icon = Icons.calendar_today_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13241C) : const Color(0xFFFBF8EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.35 : 0.4),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: FatimidColors.goldGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1B2A1E), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF0F2C22),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: FatimidColors.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
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

/// بطاقة عرض ساعة الحرمين الفاخرة على الشاشة الرئيسية
class _AlFajiaClockHeroCard extends StatelessWidget {
  const _AlFajiaClockHeroCard({
    required this.city,
    required this.onTap,
    required this.isDark,
  });

  final String city;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm').format(now);
    final amPmStr = DateFormat('a', 'ar').format(now);
    final hijri = HijriCalendar.fromDate(now);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14191F) : const Color(0xFFFAF7EE),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: FatimidColors.goldPrimary.withValues(alpha: isDark ? 0.45 : 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC5A059), Color(0xFF8A6D3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC5A059).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.access_alarm_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ساعة الحرمين الرقمية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF0F2C22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2222).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF2222).withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          'LED حي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF2222),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ساعة الفجر الجدارية الفاخرة • $city • ${hijri.hDay} ${hijri.longMonthName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0C0E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E333D), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Color(0xFFFF2222),
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    amPmStr,
                    style: const TextStyle(
                      color: Color(0xFFFFA028),
                      fontFamily: 'Cairo',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
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

/// السبحة الإلكترونية التفاعلية المدمجة في الشاشة الرئيسية
class _QuickHomeTasbeeh extends StatelessWidget {
  const _QuickHomeTasbeeh({
    required this.count,
    required this.target,
    required this.selectedPhrase,
    required this.onTap,
    required this.onReset,
    required this.onSelectNextPhrase,
    required this.isDark,
  });

  final int count;
  final int target;
  final String selectedPhrase;
  final VoidCallback onTap;
  final VoidCallback onReset;
  final VoidCallback onSelectNextPhrase;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final progress = (count / target).clamp(0.0, 1.0);

    return FatimidCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السبحة الإلكترونية السريعة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F2C22),
                    ),
                  ),
                  Text(
                    'اضغط للتسبيح • الورد اليومي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: isDark ? const Color(0xFFA5C4B8) : const Color(0xFF4A6B5F),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (count > 0)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  color: FatimidColors.goldPrimary,
                  tooltip: 'إعادة تصفير',
                  onPressed: onReset,
                ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onSelectNextPhrase,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A2620)
                    : FatimidColors.emeraldPrimary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FatimidColors.emeraldPrimary.withValues(alpha: isDark ? 0.3 : 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedPhrase,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.swap_horiz_rounded,
                    color: FatimidColors.goldPrimary.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: FatimidColors.goldPrimary.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(FatimidColors.goldPrimary),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: FatimidColors.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: FatimidColors.goldPrimary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ArabicTextUtils.toArabicDigits(count),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF14241B),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            '/ ${ArabicTextUtils.toArabicDigits(target)}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF14241B).withValues(alpha: 0.7),
                            ),
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
    );
  }
}

