class Ayah {
  const Ayah({
    required this.number,
    required this.text,
    this.globalNumber,
    this.juz,
    this.page,
    this.hizbQuarter,
  });

  final int number;
  final String text;
  final int? globalNumber;
  final int? juz;
  final int? page;
  final int? hizbQuarter;

  factory Ayah.fromJson(Map<String, dynamic> json) => Ayah(
    number: json['number'] as int,
    text: json['text'] as String,
    globalNumber: json['globalNumber'] as int?,
    juz: json['juz'] as int?,
    page: json['page'] as int?,
    hizbQuarter: json['hizbQuarter'] as int?,
  );
}

class Surah {
  const Surah({
    required this.id,
    required this.name,
    required this.ayahs,
    this.englishName,
    this.revelationType,
  });

  final int id;
  final String name;
  final List<Ayah> ayahs;
  final String? englishName;
  final String? revelationType;

  bool get isMeccan => revelationType?.toLowerCase() == 'meccan';
  String get revelationLabel => isMeccan ? 'مكية' : 'مدنية';

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
    id: json['id'] as int,
    name: json['name'] as String,
    englishName: json['englishName'] as String?,
    revelationType: json['revelationType'] as String?,
    ayahs: (json['ayahs'] as List)
        .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class QuranBookmark {
  const QuranBookmark({
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
  });
  final int surahId;
  final String surahName;
  final int ayahNumber;

  factory QuranBookmark.fromJson(Map<String, dynamic> json) => QuranBookmark(
    surahId: json['surahId'] as int,
    surahName: json['surahName'] as String,
    ayahNumber: json['ayahNumber'] as int,
  );

  Map<String, dynamic> toJson() => {
    'surahId': surahId,
    'surahName': surahName,
    'ayahNumber': ayahNumber,
  };
}
