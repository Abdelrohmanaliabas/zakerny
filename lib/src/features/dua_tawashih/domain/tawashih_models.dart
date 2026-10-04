class Munshid {
  const Munshid({
    required this.id,
    required this.name,
    required this.epithet,
    required this.bio,
    this.avatarAsset,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String epithet;
  final String bio;
  final String? avatarAsset;
  final String? photoUrl;
}

class TawashihItem {
  const TawashihItem({
    required this.id,
    required this.munshidId,
    required this.munshidName,
    required this.title,
    required this.theme,
    this.maqam,
    required this.lyrics,
    required this.audioUrl,
    this.backupUrls = const [],
    required this.durationText,
  });

  final String id;
  final String munshidId;
  final String munshidName;
  final String title;
  final String theme;
  final String? maqam;
  final String lyrics;
  final String audioUrl;
  final List<String> backupUrls;
  final String durationText;

  List<String> get allAudioUrls => [
        audioUrl,
        ...backupUrls.where((u) => u.isNotEmpty && u != audioUrl),
      ];
}
