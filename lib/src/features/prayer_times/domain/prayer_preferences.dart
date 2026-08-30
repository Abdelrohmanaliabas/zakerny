class PrayerPreferences {
  const PrayerPreferences({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.useCurrentLocation,
    required this.calculationMethod,
    required this.madhab,
    required this.reminderMinutes,
    required this.enabledPrayers,
  });

  factory PrayerPreferences.defaults() => const PrayerPreferences(
    city: 'القاهرة',
    latitude: 30.0444,
    longitude: 31.2357,
    useCurrentLocation: false,
    calculationMethod: 'egyptian',
    madhab: 'shafi',
    reminderMinutes: 10,
    enabledPrayers: {
      'fajr': true,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    },
  );

  final String city;
  final double latitude;
  final double longitude;
  final bool useCurrentLocation;
  final String calculationMethod;
  final String madhab;
  final int reminderMinutes;
  final Map<String, bool> enabledPrayers;

  PrayerPreferences copyWith({
    String? city,
    double? latitude,
    double? longitude,
    bool? useCurrentLocation,
    String? calculationMethod,
    String? madhab,
    int? reminderMinutes,
    Map<String, bool>? enabledPrayers,
  }) {
    return PrayerPreferences(
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      useCurrentLocation: useCurrentLocation ?? this.useCurrentLocation,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
    );
  }

  factory PrayerPreferences.fromJson(Map<String, dynamic> json) {
    final defaults = PrayerPreferences.defaults();
    return PrayerPreferences(
      city: json['city'] as String? ?? defaults.city,
      latitude: (json['latitude'] as num?)?.toDouble() ?? defaults.latitude,
      longitude: (json['longitude'] as num?)?.toDouble() ?? defaults.longitude,
      useCurrentLocation:
          json['useCurrentLocation'] as bool? ?? defaults.useCurrentLocation,
      calculationMethod:
          json['calculationMethod'] as String? ?? defaults.calculationMethod,
      madhab: json['madhab'] as String? ?? defaults.madhab,
      reminderMinutes:
          json['reminderMinutes'] as int? ?? defaults.reminderMinutes,
      enabledPrayers: {
        ...defaults.enabledPrayers,
        ...(json['enabledPrayers'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, value == true),
        ),
      },
    );
  }

  Map<String, dynamic> toJson() => {
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'useCurrentLocation': useCurrentLocation,
    'calculationMethod': calculationMethod,
    'madhab': madhab,
    'reminderMinutes': reminderMinutes,
    'enabledPrayers': enabledPrayers,
  };
}
