import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _prefs = widget.controller.loadPreferences();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
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
    final next = day.nextPrayer(DateTime.now());

    return Scaffold(
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
                  _NextPrayerCard(next: next),
                  const SizedBox(height: 18),
                  Text(
                    'مواقيت اليوم',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 74,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: day.prayers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final prayer = day.prayers[index];
                        return _PrayerChip(
                          prayer: prayer,
                          selected: prayer.key == next.key,
                          time: _timeFormat.format(prayer.time),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...day.prayers.map(
                    (prayer) => Card(
                      child: ListTile(
                        leading: Icon(
                          prayer.key == next.key
                              ? Icons.notifications_active
                              : Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(prayer.name),
                        subtitle: prayer.key == 'sunrise'
                            ? const Text('الشروق')
                            : Text(
                                _prefs.enabledPrayers[prayer.key] == true
                                    ? 'التنبيه مفعل'
                                    : 'التنبيه متوقف',
                              ),
                        trailing: Text(
                          _timeFormat.format(prayer.time),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
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

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.next});

  final PrayerMoment next;

  @override
  Widget build(BuildContext context) {
    final remaining = next.time.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60).clamp(0, 59);
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.volume_up, color: color.onPrimary, size: 36),
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
                  next.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'متبقي $hours ساعة و $minutes دقيقة',
                  style: TextStyle(
                    color: color.onPrimary.withValues(alpha: 0.86),
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
    required this.time,
  });

  final PrayerMoment prayer;
  final bool selected;
  final String time;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      width: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? color.secondary : color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prayer.name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.black87 : color.onSurface,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.black87 : color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
