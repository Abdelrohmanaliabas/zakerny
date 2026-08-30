import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    final lastRead = quran.lastRead();
    final downloads = recitations.downloads();
    final timeFormat = DateFormat('hh:mm a', 'ar');

    return Scaffold(
      appBar: AppBar(title: const Text('ذكرني')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeCard(
            icon: Icons.access_time,
            title: 'الصلاة القادمة',
            value: '${next.name} - ${timeFormat.format(next.time)}',
            onTap: () => context.go('/prayers'),
          ),
          _HomeCard(
            icon: Icons.menu_book,
            title: 'متابعة القراءة',
            value: lastRead == null
                ? 'لا يوجد موضع محفوظ'
                : '${lastRead.surahName}، آية ${lastRead.ayahNumber}',
            onTap: () => lastRead == null
                ? context.go('/quran')
                : context.go('/quran/surah/${lastRead.surahId}'),
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
                icon: Icons.article,
                title: 'آخر حديث',
                value: item?.title ?? 'لا توجد أحاديث محلية',
                onTap: () => context.go('/hadith'),
              );
            },
          ),
          _HomeCard(
            icon: Icons.headphones,
            title: 'التلاوات المحملة',
            value: downloads.isEmpty
                ? 'لا توجد ملفات محملة'
                : '${downloads.length} ملف جاهز دون إنترنت',
            onTap: () => context.go('/recitations'),
          ),
        ],
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
        minVerticalPadding: 18,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(value),
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
