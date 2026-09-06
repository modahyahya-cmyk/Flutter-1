import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> saveString(String key, String value);
  Future<void> saveJson(String key, Object value);
  String? getString(String key);
  dynamic getJson(String key);
  Future<void> remove(String key);
  Future<void> clearAll();
}

class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  Future<void> saveString(String key, String value) async {
    await sharedPreferences.setString(key, value);
  }

  @override
  Future<void> saveJson(String key, Object value) async {
    await sharedPreferences.setString(key, jsonEncode(value));
  }

  @override
  String? getString(String key) => sharedPreferences.getString(key);

  @override
  dynamic getJson(String key) {
    final raw = sharedPreferences.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw);
  }

  @override
  Future<void> remove(String key) async {
    await sharedPreferences.remove(key);
  }

  @override
  Future<void> clearAll() async {
    await sharedPreferences.clear();
  }
}
