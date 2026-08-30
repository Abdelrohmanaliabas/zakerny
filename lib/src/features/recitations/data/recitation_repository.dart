import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/storage/app_local_store.dart';
import '../domain/recitation_models.dart';

class RecitationRepository {
  RecitationRepository(this._store);

  static const _downloadsKey = 'downloaded_recitations';
  final AppLocalStore _store;
  List<Reciter>? _cache;

  Future<List<Reciter>> loadReciters() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/recitations/reciters.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['reciters'] as List)
        .map((e) => Reciter.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  List<DownloadedRecitation> downloads() => _store
      .getJsonList(_downloadsKey)
      .map(DownloadedRecitation.fromJson)
      .toList();

  DownloadedRecitation? findDownload(String reciterId, int surahId) {
    return downloads()
        .where((d) => d.reciterId == reciterId && d.surahId == surahId)
        .firstOrNull;
  }

  Future<void> saveDownload(DownloadedRecitation download) async {
    final items = downloads().where((d) => d.key != download.key).toList()
      ..add(download);
    await _store.setJsonList(
      _downloadsKey,
      items.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> removeDownload(String reciterId, int surahId) async {
    final items = downloads()
        .where((d) => !(d.reciterId == reciterId && d.surahId == surahId))
        .toList();
    await _store.setJsonList(
      _downloadsKey,
      items.map((e) => e.toJson()).toList(),
    );
  }
}
