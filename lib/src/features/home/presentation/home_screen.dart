import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/zekrni_header.dart';
import '../../hadith/application/hadith_controller.dart';
import '../../prayer_times/application/prayer_controller.dart';
import '../../quran/application/quran_controller.dart';
import '../../recitations/application/recitations_controller.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final prefs = prayer.loadPreferences();
    final day = prayer.today(prefs);
    final next = day.nextPrayer(DateTime.now());
    final remaining = next.time.difference(DateTime.now());
    final lastRead = quran.lastRead();
    final downloads = recitations.downloads();
    final timeFormat = DateFormat('hh:mm a', 'ar');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ZekrniHeader(
              title: 'ذكرني',
              subtitle: prefs.city,
              showSearch: true,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrayerHeroCard(
                    prayerName: next.name,
                    time: timeFormat.format(next.time),
                    remaining: remaining,
                    onTap: () => context.go('/prayers'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'من أجلك',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _QuickAction(
                        icon: Icons.explore,
                        label: 'القبلة',
                        onTap: () => context.push('/qibla'),
                      ),
                      _QuickAction(
                        icon: Icons.favorite,
                        label: 'الأذكار',
                        onTap: () => context.push('/adhkar'),
                      ),
                      _QuickAction(
                        icon: Icons.menu_book,
                        label: 'القرآن',
                        onTap: () => context.go('/quran'),
                      ),
                      _QuickAction(
                        icon: Icons.headphones,
                        label: 'قراء',
                        onTap: () => context.go('/recitations'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _HomeCard(
                    icon: Icons.menu_book,
                    title: 'متابعة القراءة',
                    value: lastRead == null
                        ? 'لا يوجد موضع محفوظ'
                        : '${lastRead.surahName}، آية ${lastRead.ayahNumber}',
                    onTap: () => lastRead == null
                        ? context.go('/quran')
                        : context.push('/quran/surah/${lastRead.surahId}'),
                  ),
                  FutureBuilder(
                    future: hadith.load(),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? const [];
                      final lastId = hadith.lastHadithId();
                      final item =
                          items.where((h) => h.id == lastId).firstOrNull ??
                          (items.isEmpty ? null : items.first);
                      return _HomeCard(
                        icon: Icons.favorite_border,
                        title: 'آخر حديث',
                        value: item?.title ?? 'لا توجد أحاديث محلية',
                        onTap: () => context.go('/hadith'),
                      );
                    },
                  ),
                  _HomeCard(
                    icon: Icons.download_done,
                    title: 'التلاوات المحملة',
                    value: downloads.isEmpty
                        ? 'لا توجد ملفات محملة'
                        : '${downloads.length} ملف جاهز دون إنترنت',
                    onTap: () => context.go('/recitations'),
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

class _PrayerHeroCard extends StatelessWidget {
  const _PrayerHeroCard({
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
    final color = Theme.of(context).colorScheme;
    final minutes = remaining.inMinutes.remainder(60).clamp(0, 59);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.primary.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.mosque, color: color.onPrimary, size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة',
                    style: TextStyle(color: color.onPrimary),
                  ),
                  Text(
                    prayerName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '$time - متبقي ${remaining.inHours} ساعة و $minutes دقيقة',
                    style: TextStyle(
                      color: color.onPrimary.withValues(alpha: 0.86),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        minVerticalPadding: 14,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
