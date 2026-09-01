class Reciter {
  const Reciter({required this.id, required this.name, required this.surahs});
  final String id;
  final String name;
  final List<RecitationSurah> surahs;

  factory Reciter.fromJson(Map<String, dynamic> json) => Reciter(
    id: json['id'] as String,
    name: json['name'] as String,
    surahs: (json['surahs'] as List)
        .map((e) => RecitationSurah.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class RecitationSurah {
  const RecitationSurah({
    required this.id,
    required this.name,
    this.url,
    this.urls = const [],
  });
  final int id;
  final String name;
  final String? url;
  final List<String> urls;

  List<String> get streamUrls {
    final ordered = <String>[
      if (url != null && url!.isNotEmpty) url!,
      ...urls.where((item) => item.isNotEmpty),
    ];
    return ordered.toSet().toList();
  }

  factory RecitationSurah.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['urls'];
    return RecitationSurah(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String?,
      urls: rawUrls is List ? rawUrls.whereType<String>().toList() : const [],
    );
  }
}

class DownloadedRecitation {
  const DownloadedRecitation({
    required this.reciterId,
    required this.surahId,
    required this.path,
  });
  final String reciterId;
  final int surahId;
  final String path;

  String get key => '$reciterId-$surahId';

  factory DownloadedRecitation.fromJson(Map<String, dynamic> json) =>
      DownloadedRecitation(
        reciterId: json['reciterId'] as String,
        surahId: json['surahId'] as int,
        path: json['path'] as String,
      );

  Map<String, dynamic> toJson() => {
    'reciterId': reciterId,
    'surahId': surahId,
    'path': path,
  };
}
