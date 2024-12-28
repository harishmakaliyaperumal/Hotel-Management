import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../common/helpers/shared_preferences_helper.dart';

class TokenProvider {
  final String baseUrl = 'https://www.hotels.annulartech.net';
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();



  Future<String?> refreshToken() async {
    try {
      // Get the refresh token (stored as 'token' during login)
      final loginData = await _prefsHelper.getLoginData();
      final refreshToken = loginData?['token'];  // Get the actual refresh token

      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      print('Using refresh token: $refreshToken'); // Debug print

      final response = await http.post(
        Uri.parse('$baseUrl/user/refreshToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': refreshToken,  // Pass the actual refresh token
        }),
      );

      print('Refresh token response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['jwt'] != null) {
          // Update only the JWT while preserving other data
          final existingData = await _prefsHelper.getLoginData() ?? {};
          await _prefsHelper.saveLoginData({
            ...existingData,
            'jwt': data['jwt'],
          });

          return data['jwt'];
        } else {
          throw Exception('No JWT in refresh response');
        }
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      await clearToken();
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _prefsHelper.getToken();
  }

  Future<void> setToken(String token) async {
    await _prefsHelper.saveToken(token);
  }

  Future<void> clearToken() async {
    await _prefsHelper.clearLoginData();
  }

  Future<bool> needsRefresh() async {
    final expiry = await _prefsHelper.getTokenExpiry();
    if (expiry == null) return true;

    final bufferTime = 5 * 60 * 1000; // 5 minutes in milliseconds
    return DateTime.now().millisecondsSinceEpoch + bufferTime >= expiry;
  }
}