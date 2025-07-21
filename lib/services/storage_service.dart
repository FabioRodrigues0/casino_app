import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const String _userKey = 'current_user';
  static const String _creditsKey = 'user_credits';
  static const String _gameHistoryKey = 'game_history';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int? getCredits() {
    return _prefs.getInt(_creditsKey);
  }

  static List<Map<String, dynamic>>? getGameHistory() {
    final historyString = _prefs.getString(_gameHistoryKey);
    if (historyString == null) return null;
    return (jsonDecode(historyString) as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<bool> updateCredits(int credits) async {
    return await _prefs.setInt(_creditsKey, credits);
  }

  static Future<bool> saveGameHistory(List<Map<String, dynamic>> history) async {
    final historyString = jsonEncode(history);
    return await _prefs.setString(_gameHistoryKey, historyString);
  }

  static Future<bool> saveUser(String username, int credits) async {
    final userData = jsonEncode({'username': username, 'credits': credits});
    return await _prefs.setString(_userKey, userData);
  }

  static Future<bool> clearUserData() async {
    return await _prefs.clear();
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
}
