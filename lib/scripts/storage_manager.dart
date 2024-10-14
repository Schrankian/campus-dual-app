import "dart:convert";

import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

enum Type { int, double, string, bool, stringList }

class StorageManager {
  dynamic _getData(SharedPreferences source, String key, {Type? type}) {
    if (type != null) {
      switch (type) {
        case Type.int:
          return source.getInt(key);
        case Type.double:
          return source.getDouble(key);
        case Type.string:
          return source.getString(key);
        case Type.bool:
          return source.getBool(key);
        case Type.stringList:
          return source.getStringList(key);
      }
    }

    if (source.containsKey(key)) {
      return source.get(key);
    }
  }

  Future<void> _saveData(SharedPreferences source, String key, dynamic value) async {
    if (value is int) {
      await source.setInt(key, value);
    }
    if (value is double) {
      await source.setDouble(key, value);
    }
    if (value is String) {
      await source.setString(key, value);
    }
    if (value is bool) {
      await source.setBool(key, value);
    }
    if (value is List<String>) {
      await source.setStringList(key, value);
    }
  }

  Future<void> clearAll() async {
    // Things to persist
    final theme = await loadTheme();
    final evaluationRules = await loadObjectList("evaluationRules");
    final useFuzzyColors = await loadBool("useFuzzyColor");

    final disk = await SharedPreferences.getInstance();
    disk.clear();
    const secureDisk = FlutterSecureStorage();
    await secureDisk.deleteAll();

    // Persist
    saveTheme(theme);
    if (evaluationRules != null) {
      saveObjectList("evaluationRules", evaluationRules);
    }
    if (useFuzzyColors != null) {
      saveBool("useFuzzyColor", useFuzzyColors);
    }
  }

  Future<UserCredentials?> loadUserAuthData() async {
    const secureDisk = FlutterSecureStorage();
    final String username = await secureDisk.read(key: "username") ?? "";
    final String password = await secureDisk.read(key: "password") ?? "";
    final String hash = await secureDisk.read(key: "hash") ?? "";
    final bool isDummy = bool.tryParse(await secureDisk.read(key: "isDummy") ?? "") ?? false;

    if (username == "" || hash == "" || password == "") {
      return null;
    }
    UserCredentials creds = UserCredentials(username, password, hash, isDummy);
    return creds;
  }

  Future<void> saveUserAuthData(UserCredentials data) async {
    const secureDisk = FlutterSecureStorage();
    secureDisk.write(key: "username", value: data.username);
    secureDisk.write(key: "password", value: data.password);
    secureDisk.write(key: "hash", value: data.hash);
    secureDisk.write(key: "isDummy", value: data.isDummy.toString());
  }

  Future<ThemeMode> loadTheme() async {
    final disk = await SharedPreferences.getInstance();
    final isDarkMode = _getData(disk, "isDarkMode");
    if (isDarkMode == null) {
      return ThemeMode.system;
    }
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> saveTheme(ThemeMode theme) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, "isDarkMode", theme == ThemeMode.dark);
  }

  Future<DateTime?> loadDateTime(String key) async {
    final disk = await SharedPreferences.getInstance();
    final dateTime = _getData(disk, key, type: Type.string);
    if (dateTime == null) {
      return null;
    }
    return DateTime.parse(dateTime);
  }

  Future<void> saveDateTime(String key, DateTime value) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, key, value.toIso8601String());
  }

  Future<Map<String, dynamic>?> loadObject(String key) async {
    final disk = await SharedPreferences.getInstance();
    final jsonData = _getData(disk, key, type: Type.string);
    if (jsonData == null) {
      return null;
    }
    return jsonDecode(jsonData);
  }

  Future<void> saveObject(String key, Object data) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, key, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>?> loadObjectList(String key) async {
    final disk = await SharedPreferences.getInstance();
    final jsonData = _getData(disk, key, type: Type.stringList) as List<String>?;
    if (jsonData == null) {
      return null;
    }
    return jsonData.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> saveObjectList(String key, List<Object> data) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, key, data.map((e) => jsonEncode(e)).toList());
  }

  Future<int?> loadInt(String key) async {
    final disk = await SharedPreferences.getInstance();
    return _getData(disk, key, type: Type.int);
  }

  Future<void> saveInt(String key, int value) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, key, value);
  }

  Future<bool?> loadBool(String key) async {
    final disk = await SharedPreferences.getInstance();
    return _getData(disk, key, type: Type.bool);
  }

  Future<void> saveBool(String key, bool value) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, key, value);
  }
}
