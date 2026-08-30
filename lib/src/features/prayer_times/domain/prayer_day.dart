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

  PrayerMoment nextPrayer(DateTime now) {
    for (final prayer in prayers.where((p) => p.key != 'sunrise')) {
      if (prayer.time.isAfter(now)) return prayer;
    }
    return prayers.first;
  }
}
