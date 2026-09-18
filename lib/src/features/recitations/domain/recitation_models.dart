class Reciter {
  const Reciter({
    required this.id,
    required this.name,
    required this.surahs,
    this.photoUrl,
    this.avatarAsset,
  });

  final String id;
  final String name;
  final List<RecitationSurah> surahs;
  final String? photoUrl;
  final String? avatarAsset;

  String get defaultAvatarAsset =>
      avatarAsset ?? 'assets/recitations/avatars/$id.webp';

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return Reciter(
      id: id,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String? ?? json['photo'] as String?,
      avatarAsset: json['avatarAsset'] as String? ??
          json['avatar'] as String? ??
          'assets/recitations/avatars/$id.webp',
      surahs: (json['surahs'] as List)
          .map((e) => RecitationSurah.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (avatarAsset != null) 'avatarAsset': avatarAsset,
    'surahs': surahs.map((e) => e.toJson()).toList(),
  };
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (url != null) 'url': url,
    'urls': urls,
  };
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

class ActiveRecitation {
  const ActiveRecitation({
    required this.reciter,
    required this.surah,
    required this.isDownloaded,
    this.localPath,
    this.ayahNumber,
    this.customTitle,
  });

  final Reciter reciter;
  final RecitationSurah surah;
  final bool isDownloaded;
  final String? localPath;
  final int? ayahNumber;
  final String? customTitle;

  String get key => ayahNumber != null
      ? '${reciter.id}-${surah.id}-$ayahNumber'
      : '${reciter.id}-${surah.id}';

  String get displayTitle {
    if (customTitle != null && customTitle!.isNotEmpty) {
      return customTitle!;
    }
    final rawName = surah.name;
    final prefix = (rawName.startsWith('سُورَة') || rawName.startsWith('سورة'))
        ? rawName
        : 'سورة $rawName';
    if (ayahNumber != null) {
      return '$prefix • آية $ayahNumber';
    }
    return prefix;
  }

  bool matches(String reciterId, int surahId, [int? ayah]) {
    if (reciter.id != reciterId || surah.id != surahId) return false;
    if (ayah != null) return ayahNumber == ayah;
    return true;
  }
}


