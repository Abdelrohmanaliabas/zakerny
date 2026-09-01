class DhikrCategory {
  const DhikrCategory({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<DhikrItem> items;

  factory DhikrCategory.fromJson(Map<String, dynamic> json) => DhikrCategory(
    id: json['id'] as String,
    title: json['title'] as String,
    items: (json['items'] as List)
        .map((item) => DhikrItem.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class DhikrItem {
  const DhikrItem({
    required this.id,
    required this.title,
    required this.text,
    required this.targetCount,
    this.source,
  });

  final String id;
  final String title;
  final String text;
  final int targetCount;
  final String? source;

  factory DhikrItem.fromJson(Map<String, dynamic> json) => DhikrItem(
    id: json['id'] as String,
    title: json['title'] as String,
    text: json['text'] as String,
    targetCount: json['targetCount'] as int? ?? 1,
    source: json['source'] as String?,
  );
}
