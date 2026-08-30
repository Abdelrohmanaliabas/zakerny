class Hadith {
  const Hadith({
    required this.id,
    required this.collection,
    required this.title,
    required this.text,
  });
  final int id;
  final String collection;
  final String title;
  final String text;

  factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
    id: json['id'] as int,
    collection: json['collection'] as String,
    title: json['title'] as String,
    text: json['text'] as String,
  );
}
