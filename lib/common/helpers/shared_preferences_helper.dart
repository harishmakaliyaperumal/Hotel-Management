import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String KEY_JWT = 'jwt';
  static const String KEY_USER_ID = 'userId';
  static const String KEY_USERNAME = 'username';
  static const String KEY_TOKEN = 'token';
  static const String KEY_USER_TYPE = 'userType';
  static const String KEY_STATUS = 'status';
  static const String KEY_ROOM_NO = 'roomNo';
  static const String KEY_FLOOR_ID = 'floorId';
  static const String KEY_EXPIRY = 'expiry';

  // Save login data
  Future<void> saveLoginData(Map<String, dynamic> loginData) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await prefs.setString(KEY_JWT, loginData['jwt'] ?? '');
      await prefs.setInt(KEY_USER_ID, _safeIntConvert(loginData['id']));
      await prefs.setString(KEY_USERNAME, loginData['username'] ?? '');
      await prefs.setString(KEY_TOKEN, loginData['token'] ?? '');
      await prefs.setString(KEY_USER_TYPE, loginData['userType'] ?? '');
      await prefs.setInt(KEY_STATUS, _safeIntConvert(loginData['status']));

      if (loginData['roomNo'] != null) {
        await prefs.setInt(KEY_ROOM_NO, _safeIntConvert(loginData['roomNo']));
      }

      if (loginData['floorId'] != null) {
        await prefs.setInt(KEY_FLOOR_ID, _safeIntConvert(loginData['floorId']));
      }
    } catch (e) {
      print('Error saving login data: $e');
      // Optionally rethrow or handle the error
    }
  }

  // Retrieve login data
  Future<Map<String, dynamic>?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(KEY_JWT)) return null;

    return {
      'jwt': prefs.getString(KEY_JWT),
      'id': prefs.getInt(KEY_USER_ID),
      'username': prefs.getString(KEY_USERNAME),
      'token': prefs.getString(KEY_TOKEN),
      'userType': prefs.getString(KEY_USER_TYPE),
      'status': prefs.getInt(KEY_STATUS),
      'roomNo': prefs.getInt(KEY_ROOM_NO),
      'floorId': prefs.getInt(KEY_FLOOR_ID),
    };
  }

  // Clear login data
  Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_TOKEN, token);
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_TOKEN);
  }

  // Save token expiry
  Future<void> saveTokenExpiry(int expiryTimestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_EXPIRY, expiryTimestamp);
  }

  // Get token expiry
  Future<int?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_EXPIRY);
  }
}

int _safeIntConvert(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
