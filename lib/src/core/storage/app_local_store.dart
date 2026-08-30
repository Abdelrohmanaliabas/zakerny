import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class AppLocalStore {
  Future<void> init();
  String? getString(String key);
  Future<void> setString(String key, String value);
  bool? getBool(String key);
  Future<void> setBool(String key, bool value);
  int? getInt(String key);
  Future<void> setInt(String key, int value);
  double? getDouble(String key);
  Future<void> setDouble(String key, double value);
  Map<String, dynamic>? getJson(String key);
  Future<void> setJson(String key, Map<String, dynamic> value);
  List<Map<String, dynamic>> getJsonList(String key);
  Future<void> setJsonList(String key, List<Map<String, dynamic>> value);
  Future<void> remove(String key);
}

class SharedPrefsAppLocalStore implements AppLocalStore {
  late final SharedPreferences _prefs;

  @override
  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  @override
  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
