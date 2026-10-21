import 'dart:convert';

import '../../../core/storage/app_local_store.dart';
import '../domain/lecture_models.dart';

class LectureRepository {
  const LectureRepository(this._store);

  final AppLocalStore _store;

  static const _downloadsKey = 'downloaded_lectures';
  static const _favoritesKey = 'favorite_lectures';
  static const _lastPlayedKey = 'last_played_lecture';
  static const _progressPrefix = 'lecture_pos_';

  List<DownloadedLecture> downloads() => _store
      .getJsonList(_downloadsKey)
      .map(DownloadedLecture.fromJson)
      .toList();

  DownloadedLecture? findDownload(String lectureId) {
    try {
      return downloads().firstWhere((d) => d.lectureId == lectureId);
    } catch (_) {
      return null;
    }
  }

  bool isDownloaded(String lectureId) => findDownload(lectureId) != null;

  Future<void> saveDownload(DownloadedLecture download) async {
    final items = downloads()
        .where((d) => d.lectureId != download.lectureId)
        .toList()
      ..add(download);
    await _store.setJsonList(
      _downloadsKey,
      items.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> removeDownload(String lectureId) async {
    final items =
        downloads().where((d) => d.lectureId != lectureId).toList();
    await _store.setJsonList(
      _downloadsKey,
      items.map((e) => e.toJson()).toList(),
    );
  }

  List<String> getFavorites() {
    final raw = _store.getString(_favoritesKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  bool isFavorite(String lectureId) => getFavorites().contains(lectureId);

  Future<void> toggleFavorite(String lectureId) async {
    final list = List<String>.from(getFavorites());
    if (list.contains(lectureId)) {
      list.remove(lectureId);
    } else {
      list.add(lectureId);
    }
    await _store.setString(_favoritesKey, jsonEncode(list));
  }

  Future<void> saveProgress(String lectureId, int seconds) async {
    await _store.setInt('$_progressPrefix$lectureId', seconds);
  }

  int getProgress(String lectureId) {
    return _store.getInt('$_progressPrefix$lectureId') ?? 0;
  }

  Future<void> saveLastPlayed(String lectureId) async {
    await _store.setString(_lastPlayedKey, lectureId);
  }

  String? getLastPlayed() {
    return _store.getString(_lastPlayedKey);
  }
}
