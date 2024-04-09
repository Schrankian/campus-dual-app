import "package:campus_dual_android/scripts/campus_dual_manager.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class StorageManager {
  dynamic _getData(SharedPreferences source, String key) {
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

  Future<UserCredentials?> loadUserAuthData() async {
    final disk = await SharedPreferences.getInstance();
    final String username = _getData(disk, "username") ?? "";
    final String password = _getData(disk, "password") ?? "";
    final String hash = _getData(disk, "hash") ?? "";

    if (username == "" || hash == "" || password == "") {
      return null;
    }
    UserCredentials creds = UserCredentials(username, password, hash);
    return creds;
  }

  void saveUserAuthData(UserCredentials data) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, "username", data.username);
    _saveData(disk, "password", data.password);
    _saveData(disk, "hash", data.hash);
  }

  Future<GeneralUserData?> loadGeneralUserData() async {
    final disk = await SharedPreferences.getInstance();
    final String firstName = _getData(disk, "firstName") ?? "";
    final String lastName = _getData(disk, "lastName") ?? "";
    final String group = _getData(disk, "group") ?? "";
    final String course = _getData(disk, "course") ?? "";

    if (firstName == "" || lastName == "" || group == "" || course == "") {
      return null;
    }

    GeneralUserData data = GeneralUserData(firstName: firstName, lastName: lastName, group: group, course: course);
    return data;
  }

  void saveGeneralUserData(GeneralUserData data) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, "firstName", data.firstName);
    _saveData(disk, "lastName", data.lastName);
    _saveData(disk, "group", data.group);
    _saveData(disk, "course", data.course);
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
}
