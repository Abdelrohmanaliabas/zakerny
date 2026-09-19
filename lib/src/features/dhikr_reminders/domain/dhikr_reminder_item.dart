class DhikrReminderItem {
  const DhikrReminderItem({
    required this.id,
    required this.title,
    required this.text,
    required this.virtue,
    this.audioAsset,
    this.spokenPhrase,
  });

  final String id;
  final String title;
  final String text;
  final String virtue;
  final String? audioAsset;
  final String? spokenPhrase;
}

const List<DhikrReminderItem> defaultDhikrReminders = [
  DhikrReminderItem(
    id: 'salawat',
    title: 'ﷺ صلّ على النبي',
    text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    virtue: '«مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللهُ عَلَيْهِ بِهَا عَشْرًا»',
    spokenPhrase: 'صلّ على محمد ﷺ',
    audioAsset: 'assets/audio/dhikr/dhikr_salawat.mp3',
  ),
  DhikrReminderItem(
    id: 'tahleel',
    title: '☝️ وَحِّدِ الله (التهليل)',
    text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    virtue: '«أَفْضَلُ مَا قُلْتُ أَنَا وَالنَّبِيُّونَ مِنْ قَبْلِي»',
    spokenPhrase: 'لا إله إلا الله',
    audioAsset: 'assets/audio/dhikr/dhikr_tahleel.mp3',
  ),
  DhikrReminderItem(
    id: 'thikr',
    title: '🌿 اذكر الله',
    text: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    virtue: '«مَثَلُ الَّذِي يَذْكُرُ رَبَّهُ وَالَّذِي لَا يَذْكُرُ رَبَّهُ مَثَلُ الحَيِّ وَالمَيِّتِ»',
    spokenPhrase: 'اذكر الله يذكركم',
    audioAsset: 'assets/audio/dhikr/dhikr_thikr.mp3',
  ),
  DhikrReminderItem(
    id: 'tasbeeh',
    title: '✨ سبحان الله وبحمده',
    text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ العَظِيمِ',
    virtue: '«كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي المِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ»',
    spokenPhrase: 'سبحان الله وبحمده، سبحان الله العظيم',
    audioAsset: 'assets/audio/dhikr/dhikr_tasbeeh.mp3',
  ),
  DhikrReminderItem(
    id: 'takbeer',
    title: '🌙 الله أكبر',
    text: 'اللهُ أَكْبَرُ كَبِيرًا، وَالحَمْدُ للهِ كَثِيرًا، وَسُبْحَانَ اللهِ بُكْرَةً وَأَصِيلًا',
    virtue: '«عَجِبْتُ لَهَا فُتِحَتْ لَهَا أَبْوَابُ السَّمَاءِ»',
    spokenPhrase: 'الله أكبر الله أكبر الله أكبر',
    audioAsset: 'assets/audio/dhikr/dhikr_takbeer.mp3',
  ),
  DhikrReminderItem(
    id: 'istighfar',
    title: '🌿 أستغفر الله وأتوب إليه',
    text: 'أَسْتَغْفِرُ اللهَ العَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الحَيُّ القَيُّومُ وَأَتُوبُ إِلَيْهِ',
    virtue: '«طُوبَى لِمَنْ وَجَدَ فِي صَحِيفَتِهِ اسْتِغْفَارًا كَثِيرًا»',
    spokenPhrase: 'أستغفر الله وأتوب إليه',
    audioAsset: 'assets/audio/dhikr/dhikr_istighfar.mp3',
  ),
  DhikrReminderItem(
    id: 'hawqala',
    title: '💎 لا حول ولا قوة إلا بالله',
    text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ العَلِيِّ العَظِيمِ',
    virtue: '«كَنْزٌ مِنْ كُنُوزِ الجَنَّةِ»',
    spokenPhrase: 'لا حول ولا قوة إلا بالله',
    audioAsset: 'assets/audio/dhikr/dhikr_hawqala.mp3',
  ),
  DhikrReminderItem(
    id: 'alhamdulillah',
    title: '🤲 الحمد لله رب العالمين',
    text: 'الحَمْدُ للهِ رَبِّ العَالَمِينَ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
    virtue: '«وَالحَمْدُ للهِ تَمْلأُ المِيزَانَ»',
    spokenPhrase: 'الحمد لله رب العالمين',
    audioAsset: 'assets/audio/dhikr/dhikr_alhamdulillah.mp3',
  ),
  DhikrReminderItem(
    id: 'subhanallah',
    title: '🌸 سبحان الله',
    text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
    virtue: 'من أعظم صيغ التسبيح والأجور المضاعفة',
    spokenPhrase: 'سبحان الله',
    audioAsset: 'assets/audio/dhikr/dhikr_subhanallah.mp3',
  ),
  DhikrReminderItem(
    id: 'baqiyat',
    title: '🌸 الباقيات الصالحات',
    text: 'سُبْحَانَ اللهِ، وَالحَمْدُ للهِ، وَلَا إِلَهَ إِلَّا اللهُ، وَاللهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ العَلِيِّ العَظِيمِ',
    virtue: '«أَحَبُّ الكَلَامِ إِلَى اللهِ أَرْبَعٌ، وَهُنَّ البَاقِيَاتُ الصَّالِحَاتُ»',
    spokenPhrase: 'سبحان الله والحمد لله ولا إله إلا الله والله أكبر',
    audioAsset: 'assets/audio/dhikr/dhikr_baqiyat.mp3',
  ),
  DhikrReminderItem(
    id: 'sayyid_istighfar',
    title: '🤲 سيد الاستغفار',
    text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
    virtue: '«مَنْ قَالَهَا مُوقِنًا بِهَا فَمَاتَ دَخَلَ الجَنَّةَ»',
    spokenPhrase: 'اللهم أنت ربي لا إله إلا أنت خلقتني وأنا عبدك...',
    audioAsset: 'assets/audio/dhikr/dhikr_sayyid_istighfar.mp3',
  ),
  DhikrReminderItem(
    id: 'yunus',
    title: '🐋 دعاء ذي النون (يونس عليه السلام)',
    text: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    virtue: '«دَعْوَةُ ذِي النُّونِ لَمْ يَدْعُ بِهَا رَجُلٌ مُسْلِمٌ فِي شَيْءٍ قَطُّ إِلَّا اسْتَجَابَ اللَّهُ لَهُ»',
    spokenPhrase: 'لا إله إلا أنت سبحانك إني كنت من الظالمين',
    audioAsset: 'assets/audio/dhikr/dhikr_yunus.mp3',
  ),
  DhikrReminderItem(
    id: 'dua_rahma',
    title: '🤍 يا حي يا قيوم',
    text: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
    virtue: 'دعاء النبي ﷺ عند الكرب وطلب العون والرحمة',
  ),
];
