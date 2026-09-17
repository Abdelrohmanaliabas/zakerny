import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/storage/app_local_store.dart';
import '../domain/quran_models.dart';

class QuranRepository {
  QuranRepository(this._store);

  static const _bookmarkKey = 'quran_bookmarks';
  static const _lastReadKey = 'quran_last_read';
  final AppLocalStore _store;
  List<Surah>? _cache;

  Future<List<Surah>> loadSurahs() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/quran/quran.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['surahs'] as List)
        .map((e) => Surah.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<Surah?> findSurah(int id) async {
    final surahs = await loadSurahs();
    return surahs.where((s) => s.id == id).firstOrNull;
  }

  List<QuranBookmark> bookmarks() =>
      _store.getJsonList(_bookmarkKey).map(QuranBookmark.fromJson).toList();

  Future<void> addBookmark(QuranBookmark bookmark) async {
    final items = bookmarks()
        .where(
          (b) =>
              !(b.surahId == bookmark.surahId &&
                  b.ayahNumber == bookmark.ayahNumber),
        )
        .toList();
    items.insert(0, bookmark);
    await _store.setJsonList(
      _bookmarkKey,
      items.map((e) => e.toJson()).toList(),
    );
  }

  QuranBookmark? lastRead() {
    final json = _store.getJson(_lastReadKey);
    return json == null ? null : QuranBookmark.fromJson(json);
  }

  Future<void> saveLastRead(QuranBookmark position) =>
      _store.setJson(_lastReadKey, position.toJson());

  static const _fontSizeKey = 'quran_font_size';
  static const _mushafModeKey = 'quran_mushaf_mode';

  double getFontSize() => _store.getDouble(_fontSizeKey) ?? 23.0;
  Future<void> setFontSize(double size) => _store.setDouble(_fontSizeKey, size);

  bool getMushafMode() => _store.getBool(_mushafModeKey) ?? true;
  Future<void> setMushafMode(bool value) =>
      _store.setBool(_mushafModeKey, value);
}

