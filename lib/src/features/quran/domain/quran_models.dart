class Ayah {
  const Ayah({required this.number, required this.text});
  final int number;
  final String text;

  factory Ayah.fromJson(Map<String, dynamic> json) =>
      Ayah(number: json['number'] as int, text: json['text'] as String);
}

class Surah {
  const Surah({required this.id, required this.name, required this.ayahs});
  final int id;
  final String name;
  final List<Ayah> ayahs;

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
    id: json['id'] as int,
    name: json['name'] as String,
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
