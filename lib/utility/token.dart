import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider {
  static final TokenProvider _instance = TokenProvider._internal();
  factory TokenProvider() => _instance;
  TokenProvider._internal();

  final String baseUrl = 'https://www.hotels.annulartech.net';
  static const String _tokenKey = 'jwt';
  static const String _tokenExpiryKey = 'token_expiry';
  bool _isRefreshing = false;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryString = prefs.getString(_tokenExpiryKey);

    if (token == null || expiryString == null) {
      return null;
    }

    final expiry = DateTime.parse(expiryString);
    final now = DateTime.now();

    // If token is about to expire in next 2 minutes, refresh it
    if (now.isAfter(expiry.subtract(Duration(minutes: 2)))) {
      return refreshToken();
    }

    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Set token expiry to 10 minutes from now
    final expiry = DateTime.now().add(Duration(minutes: 10));
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  Future<String?> refreshToken() async {
    if (_isRefreshing) {
      // Wait for the existing refresh to complete
      await Future.delayed(Duration(seconds: 1));
      return getToken();
    }

    _isRefreshing = true;
    try {
      final currentToken = await getToken();
      if (currentToken == null) {
        _isRefreshing = false;
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/user/refreshToken'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['jwt'] != null) {
          await saveToken(data['jwt']);
          _isRefreshing = false;
          return data['jwt'];
        }
      }

      // If refresh failed, clear the token
      await clearToken();
      _isRefreshing = false;
      return null;
    } catch (e) {
      print('Error refreshing token: $e');
      _isRefreshing = false;
      return null;
    }
  }
}