class TafsirEdition {
  final String id;
  final String name;
  final String author;
  final String description;

  const TafsirEdition({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
  });
}

const List<TafsirEdition> supportedTafsirs = [
  TafsirEdition(
    id: 'ar.muyassar',
    name: 'التفسير الميسر',
    author: 'مجمع الملك فهد لطباعة المصحف الشريف',
    description: 'تفسير موجز وموثق صادر عن نخبة من كبار العلماء بمجمع الملك فهد',
  ),
  TafsirEdition(
    id: 'ar.jalalayn',
    name: 'تفسير الجلالين',
    author: 'الإمامان جلال الدين المحلي وجلال الدين السيوطي',
    description: 'من أشهر كتب التفسير بالمأثور وأدقها عبارة وإيجازاً',
  ),
  TafsirEdition(
    id: 'ar.saadi',
    name: 'تفسير السعدي',
    author: 'الشيخ عبد الرحمن بن ناصر السعدي',
    description: 'تيسير الكريم الرحمن في تفسير كلام المنان - بأسلوب سهل وواضح',
  ),
  TafsirEdition(
    id: 'ar.ibnkathir',
    name: 'تفسير ابن كثير',
    author: 'الحافظ عماد الدين إسماعيل بن كثير',
    description: 'عمدة كتب التفسير بالرواية والأحاديث النبوية والآثار',
  ),
];

class AyahTafsir {
  final int surahId;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final String editionId;
  final String editionName;
  final String text;
  final bool isCached;

  const AyahTafsir({
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.editionId,
    required this.editionName,
    required this.text,
    this.isCached = false,
  });

  factory AyahTafsir.fromJson(Map<String, dynamic> json) => AyahTafsir(
    surahId: json['surahId'] as int,
    surahName: json['surahName'] as String? ?? '',
    ayahNumber: json['ayahNumber'] as int,
    ayahText: json['ayahText'] as String? ?? '',
    editionId: json['editionId'] as String,
    editionName: json['editionName'] as String,
    text: json['text'] as String,
    isCached: json['isCached'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'surahId': surahId,
    'surahName': surahName,
    'ayahNumber': ayahNumber,
    'ayahText': ayahText,
    'editionId': editionId,
    'editionName': editionName,
    'text': text,
    'isCached': isCached,
  };
}
