import "package:shared_preferences/shared_preferences.dart";

class UserCredentials {
  String username;
  String hash;

  UserCredentials(this.username, this.hash);
}

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

  Future<UserCredentials> loadUserAuthData() async {
    final disk = await SharedPreferences.getInstance();
    UserCredentials creds = UserCredentials(_getData(disk, "username"), _getData(disk, "hash"));
    return creds;
  }

  void saveUsername(String username) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, "username", username);
  }

  void saveHash(String hash) async {
    final disk = await SharedPreferences.getInstance();
    _saveData(disk, "hash", hash);
  }
}
