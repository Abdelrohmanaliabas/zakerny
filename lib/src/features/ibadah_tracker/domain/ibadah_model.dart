enum PrayerStatus {
  notDone,
  done,
  inJamaah;

  String get label {
    switch (this) {
      case PrayerStatus.notDone:
        return 'لم أصلي';
      case PrayerStatus.done:
        return 'صليت';
      case PrayerStatus.inJamaah:
        return 'في جماعة';
    }
  }
}

class DailyIbadahRecord {
  const DailyIbadahRecord({
    required this.dateStr, // YYYY-MM-DD
    this.fajr = PrayerStatus.notDone,
    this.dhuhr = PrayerStatus.notDone,
    this.asr = PrayerStatus.notDone,
    this.maghrib = PrayerStatus.notDone,
    this.isha = PrayerStatus.notDone,
    this.duha = false,
    this.witr = false,
    this.rawatib = false,
    this.quranWard = false,
    this.morningDhikr = false,
    this.eveningDhikr = false,
    this.fasting = false,
    this.sadaqah = false,
  });

  final String dateStr;
  final PrayerStatus fajr;
  final PrayerStatus dhuhr;
  final PrayerStatus asr;
  final PrayerStatus maghrib;
  final PrayerStatus isha;
  final bool duha;
  final bool witr;
  final bool rawatib;
  final bool quranWard;
  final bool morningDhikr;
  final bool eveningDhikr;
  final bool fasting;
  final bool sadaqah;

  int get fardPrayersDoneCount {
    var count = 0;
    if (fajr != PrayerStatus.notDone) count++;
    if (dhuhr != PrayerStatus.notDone) count++;
    if (asr != PrayerStatus.notDone) count++;
    if (maghrib != PrayerStatus.notDone) count++;
    if (isha != PrayerStatus.notDone) count++;
    return count;
  }

  int get jamaahPrayersCount {
    var count = 0;
    if (fajr == PrayerStatus.inJamaah) count++;
    if (dhuhr == PrayerStatus.inJamaah) count++;
    if (asr == PrayerStatus.inJamaah) count++;
    if (maghrib == PrayerStatus.inJamaah) count++;
    if (isha == PrayerStatus.inJamaah) count++;
    return count;
  }

  double get completionScore {
    // 5 Fard prayers: 50% (10% each, +2% bonus for Jamaah)
    // Sunnahs: 50% (Duha 10%, Witr 10%, Rawatib 10%, Quran 10%, Dhikr 10%)
    var score = 0.0;
    if (fajr != PrayerStatus.notDone) score += (fajr == PrayerStatus.inJamaah ? 12 : 10);
    if (dhuhr != PrayerStatus.notDone) score += (dhuhr == PrayerStatus.inJamaah ? 12 : 10);
    if (asr != PrayerStatus.notDone) score += (asr == PrayerStatus.inJamaah ? 12 : 10);
    if (maghrib != PrayerStatus.notDone) score += (maghrib == PrayerStatus.inJamaah ? 12 : 10);
    if (isha != PrayerStatus.notDone) score += (isha == PrayerStatus.inJamaah ? 12 : 10);

    if (duha) score += 8;
    if (witr) score += 10;
    if (rawatib) score += 8;
    if (quranWard) score += 10;
    if (morningDhikr) score += 5;
    if (eveningDhikr) score += 5;
    if (sadaqah) score += 4;

    return score.clamp(0.0, 100.0);
  }

  DailyIbadahRecord copyWith({
    String? dateStr,
    PrayerStatus? fajr,
    PrayerStatus? dhuhr,
    PrayerStatus? asr,
    PrayerStatus? maghrib,
    PrayerStatus? isha,
    bool? duha,
    bool? witr,
    bool? rawatib,
    bool? quranWard,
    bool? morningDhikr,
    bool? eveningDhikr,
    bool? fasting,
    bool? sadaqah,
  }) {
    return DailyIbadahRecord(
      dateStr: dateStr ?? this.dateStr,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      duha: duha ?? this.duha,
      witr: witr ?? this.witr,
      rawatib: rawatib ?? this.rawatib,
      quranWard: quranWard ?? this.quranWard,
      morningDhikr: morningDhikr ?? this.morningDhikr,
      eveningDhikr: eveningDhikr ?? this.eveningDhikr,
      fasting: fasting ?? this.fasting,
      sadaqah: sadaqah ?? this.sadaqah,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateStr': dateStr,
        'fajr': fajr.index,
        'dhuhr': dhuhr.index,
        'asr': asr.index,
        'maghrib': maghrib.index,
        'isha': isha.index,
        'duha': duha,
        'witr': witr,
        'rawatib': rawatib,
        'quranWard': quranWard,
        'morningDhikr': morningDhikr,
        'eveningDhikr': eveningDhikr,
        'fasting': fasting,
        'sadaqah': sadaqah,
      };

  factory DailyIbadahRecord.fromJson(Map<String, dynamic> json) {
    return DailyIbadahRecord(
      dateStr: json['dateStr'] as String? ?? '',
      fajr: PrayerStatus.values[(json['fajr'] as num?)?.toInt() ?? 0],
      dhuhr: PrayerStatus.values[(json['dhuhr'] as num?)?.toInt() ?? 0],
      asr: PrayerStatus.values[(json['asr'] as num?)?.toInt() ?? 0],
      maghrib: PrayerStatus.values[(json['maghrib'] as num?)?.toInt() ?? 0],
      isha: PrayerStatus.values[(json['isha'] as num?)?.toInt() ?? 0],
      duha: json['duha'] as bool? ?? false,
      witr: json['witr'] as bool? ?? false,
      rawatib: json['rawatib'] as bool? ?? false,
      quranWard: json['quranWard'] as bool? ?? false,
      morningDhikr: json['morningDhikr'] as bool? ?? false,
      eveningDhikr: json['eveningDhikr'] as bool? ?? false,
      fasting: json['fasting'] as bool? ?? false,
      sadaqah: json['sadaqah'] as bool? ?? false,
    );
  }
}
