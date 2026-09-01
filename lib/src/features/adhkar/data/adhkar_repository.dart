import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/storage/app_local_store.dart';
import '../domain/dhikr_models.dart';

class AdhkarRepository {
  AdhkarRepository(this._store);

  static const _countsKey = 'adhkar_counts';
  final AppLocalStore _store;
  List<DhikrCategory>? _cache;

  Future<List<DhikrCategory>> loadCategories() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/adhkar/adhkar.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['categories'] as List)
        .map((item) => DhikrCategory.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  int countFor(String dhikrId) => _counts()[dhikrId] ?? 0;

  Future<int> increment(DhikrItem item) async {
    final counts = _counts();
    final current = counts[item.id] ?? 0;
    final next = current >= item.targetCount ? item.targetCount : current + 1;
    counts[item.id] = next;
    await _store.setJson(_countsKey, counts);
    return next;
  }

  Future<void> reset(String dhikrId) async {
    final counts = _counts();
    counts.remove(dhikrId);
    await _store.setJson(_countsKey, counts);
  }

  Map<String, int> _counts() {
    final json = _store.getJson(_countsKey) ?? const <String, dynamic>{};
    return json.map((key, value) => MapEntry(key, value is int ? value : 0));
  }
}
