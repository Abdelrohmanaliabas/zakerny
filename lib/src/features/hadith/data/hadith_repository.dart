import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/storage/app_local_store.dart';
import '../domain/hadith_models.dart';

class HadithRepository {
  HadithRepository(this._store);

  static const _lastHadithKey = 'last_hadith_id';
  final AppLocalStore _store;
  List<Hadith>? _cache;

  Future<List<Hadith>> loadHadiths() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/hadith/hadith.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['hadiths'] as List)
        .map((e) => Hadith.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<Hadith>> search(String query) async {
    final all = await loadHadiths();
    final trimmed = query.trim();
    if (trimmed.isEmpty) return all;
    return all
        .where(
          (h) =>
              h.text.contains(trimmed) ||
              h.title.contains(trimmed) ||
              h.collection.contains(trimmed),
        )
        .toList();
  }

  int? lastHadithId() => _store.getInt(_lastHadithKey);
  Future<void> saveLastHadith(int id) => _store.setInt(_lastHadithKey, id);
}
