import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = "auth_token";
  static const String _userKey = "auth_user";

  /// Login — POST email + password + device_name, save token on success.
  /// Returns a Map with 'success' bool and either 'user' data or 'message'.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "device_name": deviceName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data["token"];
        final user = data["user"];

        // Persist token + user locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(user));

        return {"success": true, "user": user, "token": token};
      } else {
        // Laravel validation errors come as { "message": ..., "errors": {...} }
        final message = data["message"] ??
            (data["errors"] != null
                ? data["errors"].values.first[0]
                : "Login failed");
        return {"success": false, "message": message};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// Logout — revoke token on server, then clear local storage.
  static Future<bool> logout() async {
    final token = await getToken();
    if (token == null) return true;

    try {
      await http.post(
        Uri.parse(ApiConfig.logoutUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    } catch (_) {
      // Even if the network call fails, clear local session anyway
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    return true;
  }

  /// Get the saved token, or null if not logged in.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get the saved user data, or null if not logged in.
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  /// Quick check — is there a saved session?
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Verify the saved token is still valid by calling /api/user.
  /// Useful on app startup to decide: go to Home or go to Login.
  static Future<bool> verifyToken() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.userUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}