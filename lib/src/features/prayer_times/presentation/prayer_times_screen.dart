import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(title: const Text('مواقيت الصلاة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NextPrayerCard(next: next),
          const SizedBox(height: 12),
          ...day.prayers.map(
            (prayer) => Card(
              child: ListTile(
                leading: Icon(
                  prayer.key == next.key
                      ? Icons.notifications_active
                      : Icons.access_time,
                ),
                title: Text(prayer.name),
                subtitle: prayer.key == 'sunrise'
                    ? const Text('ليست صلاة')
                    : null,
                trailing: Text(
                  _timeFormat.format(prayer.time),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
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
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الصلاة القادمة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              next.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'متبقي $hours ساعة و $minutes دقيقة',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
