import 'dart:convert';

import '../../../core/storage/app_local_store.dart';
import '../domain/dua_models.dart';
import '../domain/tawashih_models.dart';
import 'duas_data.dart';
import 'tawashih_data.dart';

class DuaTawashihRepository {
  DuaTawashihRepository(this._store);

  final AppLocalStore _store;

  static const String _favoriteDuasKey = 'favorite_duas_list_v1';
  static const String _favoriteTawashihKey = 'favorite_tawashih_list_v1';
  static const String _duaCountsPrefix = 'dua_counter_';

  List<DuaItem> getDuas() => DuasData.allDuas;

  List<Munshid> getMunshidin() => TawashihData.allMunshidin;

  List<TawashihItem> getTawashih() => TawashihData.allTawashih;

  Set<String> getFavoriteDuas() {
    final raw = _store.getString(_favoriteDuasKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> toggleFavoriteDua(String id) async {
    final favs = getFavoriteDuas();
    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }
    await _store.setString(_favoriteDuasKey, jsonEncode(favs.toList()));
  }

  bool isDuaFavorite(String id) => getFavoriteDuas().contains(id);

  Set<String> getFavoriteTawashih() {
    final raw = _store.getString(_favoriteTawashihKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> toggleFavoriteTawashih(String id) async {
    final favs = getFavoriteTawashih();
    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }
    await _store.setString(_favoriteTawashihKey, jsonEncode(favs.toList()));
  }

  bool isTawashihFavorite(String id) => getFavoriteTawashih().contains(id);

  int getDuaCount(String id) {
    return _store.getInt('$_duaCountsPrefix$id') ?? 0;
  }

  Future<void> setDuaCount(String id, int count) async {
    await _store.setInt('$_duaCountsPrefix$id', count);
  }

  Future<void> resetDuaCount(String id) async {
    await _store.setInt('$_duaCountsPrefix$id', 0);
  }

  static const String _ruqyahCountsPrefix = 'ruqyah_counter_';

  int getRuqyahCount(String id) {
    return _store.getInt('$_ruqyahCountsPrefix$id') ?? 0;
  }

  Future<void> setRuqyahCount(String id, int count) async {
    await _store.setInt('$_ruqyahCountsPrefix$id', count);
  }

  Future<void> resetRuqyahCount(String id) async {
    await _store.setInt('$_ruqyahCountsPrefix$id', 0);
  }
}
