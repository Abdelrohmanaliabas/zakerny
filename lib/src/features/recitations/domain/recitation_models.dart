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
  const RecitationSurah({required this.id, required this.name, this.url});
  final int id;
  final String name;
  final String? url;

  factory RecitationSurah.fromJson(Map<String, dynamic> json) =>
      RecitationSurah(
        id: json['id'] as int,
        name: json['name'] as String,
        url: json['url'] as String?,
      );
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
