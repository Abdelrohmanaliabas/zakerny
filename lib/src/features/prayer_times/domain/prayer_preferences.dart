import 'adhan_voice.dart';

const List<String> defaultEnabledDhikrIds = [
  'salawat',
  'tahleel',
  'thikr',
  'tasbeeh',
  'takbeer',
  'istighfar',
  'hawqala',
  'alhamdulillah',
  'subhanallah',
  'baqiyat',
  'sayyid_istighfar',
  'yunus',
];

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
    this.overlayOnAdhan = true,
    this.adhanVoice = 'adhan_makkah',
    this.dhikrReminderEnabled = true,
    this.dhikrIntervalMinutes = 60,
    this.dhikrOverlayEnabled = true,
    this.dhikrVoiceEnabled = true,
    this.enabledDhikrIds = defaultEnabledDhikrIds,
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
    overlayOnAdhan: true,
    adhanVoice: 'adhan_makkah',
    dhikrReminderEnabled: true,
    dhikrIntervalMinutes: 60,
    dhikrOverlayEnabled: true,
    dhikrVoiceEnabled: true,
    enabledDhikrIds: defaultEnabledDhikrIds,
  );

  final String city;
  final double latitude;
  final double longitude;
  final bool useCurrentLocation;
  final String calculationMethod;
  final String madhab;
  final int reminderMinutes;
  final Map<String, bool> enabledPrayers;
  final bool overlayOnAdhan;
  final String adhanVoice;
  final bool dhikrReminderEnabled;
  final int dhikrIntervalMinutes;
  final bool dhikrOverlayEnabled;
  final bool dhikrVoiceEnabled;
  final List<String> enabledDhikrIds;

  AdhanVoice get selectedVoice => getAdhanVoiceById(adhanVoice);

  PrayerPreferences copyWith({
    String? city,
    double? latitude,
    double? longitude,
    bool? useCurrentLocation,
    String? calculationMethod,
    String? madhab,
    int? reminderMinutes,
    Map<String, bool>? enabledPrayers,
    bool? overlayOnAdhan,
    String? adhanVoice,
    bool? dhikrReminderEnabled,
    int? dhikrIntervalMinutes,
    bool? dhikrOverlayEnabled,
    bool? dhikrVoiceEnabled,
    List<String>? enabledDhikrIds,
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
      overlayOnAdhan: overlayOnAdhan ?? this.overlayOnAdhan,
      adhanVoice: adhanVoice ?? this.adhanVoice,
      dhikrReminderEnabled: dhikrReminderEnabled ?? this.dhikrReminderEnabled,
      dhikrIntervalMinutes: dhikrIntervalMinutes ?? this.dhikrIntervalMinutes,
      dhikrOverlayEnabled: dhikrOverlayEnabled ?? this.dhikrOverlayEnabled,
      dhikrVoiceEnabled: dhikrVoiceEnabled ?? this.dhikrVoiceEnabled,
      enabledDhikrIds: enabledDhikrIds ?? this.enabledDhikrIds,
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
      overlayOnAdhan:
          json['overlayOnAdhan'] as bool? ?? defaults.overlayOnAdhan,
      adhanVoice: json['adhanVoice'] as String? ?? defaults.adhanVoice,
      dhikrReminderEnabled:
          json['dhikrReminderEnabled'] as bool? ?? defaults.dhikrReminderEnabled,
      dhikrIntervalMinutes:
          json['dhikrIntervalMinutes'] as int? ?? defaults.dhikrIntervalMinutes,
      dhikrOverlayEnabled:
          json['dhikrOverlayEnabled'] as bool? ?? defaults.dhikrOverlayEnabled,
      dhikrVoiceEnabled:
          json['dhikrVoiceEnabled'] as bool? ?? defaults.dhikrVoiceEnabled,
      enabledDhikrIds: (json['enabledDhikrIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          defaults.enabledDhikrIds,
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
    'overlayOnAdhan': overlayOnAdhan,
    'adhanVoice': adhanVoice,
    'dhikrReminderEnabled': dhikrReminderEnabled,
    'dhikrIntervalMinutes': dhikrIntervalMinutes,
    'dhikrOverlayEnabled': dhikrOverlayEnabled,
    'dhikrVoiceEnabled': dhikrVoiceEnabled,
    'enabledDhikrIds': enabledDhikrIds,
  };
}
