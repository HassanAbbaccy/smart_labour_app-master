import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SessionService {
  static const String _keyLastActive = 'last_active_timestamp';
  static const int _timeoutDurationSeconds = 120; // 2 minutes

  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Mark the time when app goes into background
  Future<void> markBackgroundTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_keyLastActive, timestamp);
    debugPrint('Session marked at: $timestamp');
  }

  // Check if the session has expired
  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_keyLastActive);

    if (lastActive == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = (now - lastActive) / 1000;

    debugPrint('Session age: ${diff.toStringAsFixed(1)}s (Limit: $_timeoutDurationSeconds s)');

    return diff > _timeoutDurationSeconds;
  }

  // Clear the timestamp (e.g., after successful resume or logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastActive);
    debugPrint('Session cleared');
  }
}
