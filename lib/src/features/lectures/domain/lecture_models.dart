class Sheikh {
  const Sheikh({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    this.avatarAsset,
    this.colorHex = 0xFF0D9488,
  });

  final String id;
  final String name;
  final String title;
  final String bio;
  final String? avatarAsset;
  final int colorHex;

  factory Sheikh.fromJson(Map<String, dynamic> json) => Sheikh(
        id: json['id'] as String,
        name: json['name'] as String,
        title: json['title'] as String,
        bio: json['bio'] as String,
        avatarAsset: json['avatarAsset'] as String?,
        colorHex: json['colorHex'] as int? ?? 0xFF0D9488,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'bio': bio,
        if (avatarAsset != null) 'avatarAsset': avatarAsset,
        'colorHex': colorHex,
      };
}

enum LectureCategory {
  all,
  series,
  khutbah,
  spiritual,
  seerah,
  aqeedah,
  downloaded,
}

extension LectureCategoryX on LectureCategory {
  String get label {
    switch (this) {
      case LectureCategory.all:
        return 'الكل';
      case LectureCategory.series:
        return 'سلاسل الدروس 📚';
      case LectureCategory.khutbah:
        return 'خطب ومواعظ 🎙️';
      case LectureCategory.spiritual:
        return 'رقائق وتزكية 🤍';
      case LectureCategory.seerah:
        return 'السيرة والقصص 📜';
      case LectureCategory.aqeedah:
        return 'عقيدة وفقه 📖';
      case LectureCategory.downloaded:
        return 'المحملة أوفلاين 💾';
    }
  }
}

class LectureSeries {
  const LectureSeries({
    required this.id,
    required this.title,
    required this.sheikhId,
    required this.sheikhName,
    required this.description,
    required this.category,
    this.coverAsset,
    this.totalEpisodes = 0,
  });

  final String id;
  final String title;
  final String sheikhId;
  final String sheikhName;
  final String description;
  final LectureCategory category;
  final String? coverAsset;
  final int totalEpisodes;

  factory LectureSeries.fromJson(Map<String, dynamic> json) => LectureSeries(
        id: json['id'] as String,
        title: json['title'] as String,
        sheikhId: json['sheikhId'] as String,
        sheikhName: json['sheikhName'] as String,
        description: json['description'] as String,
        category: LectureCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => LectureCategory.series,
        ),
        coverAsset: json['coverAsset'] as String?,
        totalEpisodes: json['totalEpisodes'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'sheikhId': sheikhId,
        'sheikhName': sheikhName,
        'description': description,
        'category': category.name,
        if (coverAsset != null) 'coverAsset': coverAsset,
        'totalEpisodes': totalEpisodes,
      };
}

class LectureItem {
  const LectureItem({
    required this.id,
    required this.title,
    required this.sheikhId,
    required this.sheikhName,
    this.seriesId,
    this.seriesTitle,
    required this.audioUrl,
    this.videoUrl,
    this.backupUrls = const [],
    this.durationText = '',
    this.durationSeconds,
    this.category = LectureCategory.spiritual,
    this.description,
    this.orderIndex = 0,
  });

  final String id;
  final String title;
  final String sheikhId;
  final String sheikhName;
  final String? seriesId;
  final String? seriesTitle;
  final String audioUrl;
  final String? videoUrl;
  final List<String> backupUrls;
  final String durationText;
  final int? durationSeconds;
  final LectureCategory category;
  final String? description;
  final int orderIndex;

  List<String> get allUrls => [audioUrl, ...backupUrls];

  bool get hasVideo => videoUrl != null && videoUrl!.trim().isNotEmpty;

  factory LectureItem.fromJson(Map<String, dynamic> json) {
    final rawBackup = json['backupUrls'];
    return LectureItem(
      id: json['id'] as String,
      title: json['title'] as String,
      sheikhId: json['sheikhId'] as String,
      sheikhName: json['sheikhName'] as String,
      seriesId: json['seriesId'] as String?,
      seriesTitle: json['seriesTitle'] as String?,
      audioUrl: json['audioUrl'] as String,
      videoUrl: json['videoUrl'] as String?,
      backupUrls: rawBackup is List ? rawBackup.cast<String>() : const [],
      durationText: json['durationText'] as String? ?? '',
      durationSeconds: json['durationSeconds'] as int?,
      category: LectureCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => LectureCategory.spiritual,
      ),
      description: json['description'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'sheikhId': sheikhId,
        'sheikhName': sheikhName,
        if (seriesId != null) 'seriesId': seriesId,
        if (seriesTitle != null) 'seriesTitle': seriesTitle,
        'audioUrl': audioUrl,
        if (videoUrl != null) 'videoUrl': videoUrl,
        'backupUrls': backupUrls,
        'durationText': durationText,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        'category': category.name,
        if (description != null) 'description': description,
        'orderIndex': orderIndex,
      };
}

class DownloadedLecture {
  const DownloadedLecture({
    required this.lectureId,
    required this.localPath,
    required this.downloadedAt,
    this.fileSizeBytes,
  });

  final String lectureId;
  final String localPath;
  final String downloadedAt;
  final int? fileSizeBytes;

  factory DownloadedLecture.fromJson(Map<String, dynamic> json) =>
      DownloadedLecture(
        lectureId: json['lectureId'] as String,
        localPath: json['localPath'] as String,
        downloadedAt: json['downloadedAt'] as String,
        fileSizeBytes: json['fileSizeBytes'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'lectureId': lectureId,
        'localPath': localPath,
        'downloadedAt': downloadedAt,
        if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
      };
}

class ActiveLecture {
  const ActiveLecture({
    required this.lecture,
    required this.isDownloaded,
    this.localPath,
  });

  final LectureItem lecture;
  final bool isDownloaded;
  final String? localPath;
}
