import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction for simple key/value local persistence (non-secret data).
abstract class LocalStorage {
  Future<void> saveString(String key, String value);
  String? getString(String key);
  Future<void> saveJson(String key, Object value);
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
  String? getString(String key) => sharedPreferences.getString(key);

  @override
  Future<void> saveJson(String key, Object value) async {
    await sharedPreferences.setString(key, jsonEncode(value));
  }

  @override
  dynamic getJson(String key) {
    final raw = sharedPreferences.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
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
