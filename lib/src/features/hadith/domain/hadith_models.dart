class Hadith {
  const Hadith({
    required this.id,
    required this.collection,
    required this.title,
    required this.text,
    this.narrator,
    this.grade = 'صحيح',
  });

  final int id;
  final String collection;
  final String title;
  final String text;
  final String? narrator;
  final String grade;

  factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
    id: json['id'] as int,
    collection: json['collection'] as String,
    title: json['title'] as String,
    text: json['text'] as String,
    narrator: json['narrator'] as String? ?? json['rawahu'] as String?,
    grade: json['grade'] as String? ?? 'صحيح',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'collection': collection,
    'title': title,
    'text': text,
    if (narrator != null) 'narrator': narrator,
    'grade': grade,
  };
}
