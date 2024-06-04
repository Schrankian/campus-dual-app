import "dart:convert";

import "package:campus_dual_android/scripts/campus_dual_manager.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

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

  void _saveData(SharedPreferences source, String key, dynamic value) async {
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

  void clearAll() async {
    final disk = await SharedPreferences.getInstance();
    disk.clear();
  }

  Future<UserCredentials?> loadUserAuthData() async {
    final disk = await SharedPreferences.getInstance();
    final String username = _getData(disk, "username") ?? "";
    final String password = _getData(disk, "password") ?? "";
    final String hash = _getData(disk, "hash") ?? "";
    final bool isDummy = _getData(disk, "isDummy") ?? false;

    if (username == "" || hash == "" || password == "") {
      return null;
    }
    UserCredentials creds = UserCredentials(username, password, hash, isDummy);
    return creds;
  }

  void saveUserAuthData(UserCredentials data) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, "username", data.username);
    _saveData(disk, "password", data.password);
    _saveData(disk, "hash", data.hash);
    _saveData(disk, "isDummy", data.isDummy);
  }

  Future<ThemeMode> loadTheme() async {
    final disk = await SharedPreferences.getInstance();
    final isDarkMode = _getData(disk, "isDarkMode");
    if (isDarkMode == null) {
      return ThemeMode.system;
    }
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void saveTheme(ThemeMode theme) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, "isDarkMode", theme == ThemeMode.dark);
  }

  Future<Map<String, dynamic>?> loadObject(String key) async {
    final disk = await SharedPreferences.getInstance();
    final jsonData = _getData(disk, key, type: Type.string);
    if (jsonData == null) {
      return null;
    }
    return jsonDecode(jsonData);
  }

  void saveObject(String key, Object data) async {
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

  void saveObjectList(String key, List<Object> data) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, key, data.map((e) => jsonEncode(e)).toList());
  }

  Future<int?> loadInt(String key) async {
    final disk = await SharedPreferences.getInstance();
    return _getData(disk, key, type: Type.int);
  }

  void saveInt(String key, int value) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, key, value);
  }
}
