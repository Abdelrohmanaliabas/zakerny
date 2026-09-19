class PrayerMoment {
  const PrayerMoment({
    required this.key,
    required this.name,
    required this.time,
  });

  final String key;
  final String name;
  final DateTime time;
}

class PrayerDay {
  const PrayerDay({required this.prayers});

  final List<PrayerMoment> prayers;

  PrayerMoment nextPrayer(DateTime now, {PrayerDay? tomorrow}) {
    for (final prayer in prayers.where((p) => p.key != 'sunrise')) {
      if (prayer.time.isAfter(now)) return prayer;
    }
    if (tomorrow != null && tomorrow.prayers.isNotEmpty) {
      return tomorrow.prayers.firstWhere(
        (p) => p.key == 'fajr',
        orElse: () => tomorrow.prayers.first,
      );
    }
    final fajr = prayers.firstWhere(
      (p) => p.key == 'fajr',
      orElse: () => prayers.first,
    );
    return PrayerMoment(
      key: fajr.key,
      name: fajr.name,
      time: fajr.time.add(const Duration(days: 1)),
    );
  }
}
