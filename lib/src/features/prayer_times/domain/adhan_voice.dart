class AdhanVoice {
  const AdhanVoice({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.assetPath,
    required this.rawSoundName,
    required this.channelId,
  });

  final String id;
  final String name;
  final String subtitle;
  final String assetPath;
  final String rawSoundName;
  final String channelId;
}

const List<AdhanVoice> supportedAdhanVoices = [
  AdhanVoice(
    id: 'adhan_makkah',
    name: 'الحرم المكي الشريف',
    subtitle: 'الشيخ علي أحمد ملا',
    assetPath: 'assets/audio/adhan_makkah.mp3',
    rawSoundName: 'adhan_makkah',
    channelId: 'prayer_times_adhan_makkah',
  ),
  AdhanVoice(
    id: 'adhan_madinah',
    name: 'الحرم النبوي الشريف',
    subtitle: 'أذان المسجد النبوي بالمدينة',
    assetPath: 'assets/audio/adhan_madinah.mp3',
    rawSoundName: 'adhan_madinah',
    channelId: 'prayer_times_adhan_madinah',
  ),
  AdhanVoice(
    id: 'adhan_alafasy',
    name: 'الشيخ مشاري راشد العفاسي',
    subtitle: 'أذان ندي وخاشع',
    assetPath: 'assets/audio/adhan_alafasy.mp3',
    rawSoundName: 'adhan_alafasy',
    channelId: 'prayer_times_adhan_alafasy',
  ),
  AdhanVoice(
    id: 'adhan_abdulbasit',
    name: 'الشيخ عبد الباسط عبد الصمد',
    subtitle: 'من روائع الأذان التاريخي الخالد',
    assetPath: 'assets/audio/adhan_abdulbasit.mp3',
    rawSoundName: 'adhan_abdulbasit',
    channelId: 'prayer_times_adhan_abdulbasit',
  ),
  AdhanVoice(
    id: 'adhan_quds',
    name: 'المسجد الأقصى المبارك',
    subtitle: 'أذان القدس الشريف - الشيخ ناجي قزاز',
    assetPath: 'assets/audio/adhan_quds.mp3',
    rawSoundName: 'adhan_quds',
    channelId: 'prayer_times_adhan_quds',
  ),
  AdhanVoice(
    id: 'adhan_qatami',
    name: 'الشيخ ناصر القطامي',
    subtitle: 'أذان هادئ ومؤثر',
    assetPath: 'assets/audio/adhan_qatami.mp3',
    rawSoundName: 'adhan_qatami',
    channelId: 'prayer_times_adhan_qatami',
  ),
];

AdhanVoice getAdhanVoiceById(String? id) {
  return supportedAdhanVoices.firstWhere(
    (voice) => voice.id == id,
    orElse: () => supportedAdhanVoices.first,
  );
}
