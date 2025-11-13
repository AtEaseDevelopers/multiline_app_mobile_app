import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app lock state
class AppLockService {
  // Storage keys
  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyLastBackgroundTime = 'last_background_time';
  static const String _keyLockTimeout = 'lock_timeout_seconds';

  // Session flag to track if user has already unlocked during this session
  static bool _hasUnlockedThisSession = false;

  // Default lock timeout: 0 = immediate, 30 = 30 seconds
  static const int _defaultLockTimeout =
      0; // Lock immediately when app goes to background

  /// Check if app lock is enabled
  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAppLockEnabled) ?? false;
  }

  /// Enable or disable app lock
  static Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);
    print('🔐 App lock ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Get lock timeout in seconds
  static Future<int> getLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLockTimeout) ?? _defaultLockTimeout;
  }

  /// Set lock timeout in seconds (0 = immediate)
  static Future<void> setLockTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLockTimeout, seconds);
  }

  /// Record when app went to background
  static Future<void> recordBackgroundTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_keyLastBackgroundTime, now);
    print('📱 App went to background at: ${DateTime.now()}');
  }

  /// Check if app should be locked based on time in background
  static Future<bool> shouldLockApp() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackgroundTime = prefs.getInt(_keyLastBackgroundTime);
    if (lastBackgroundTime == null) {
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceBackground =
        (now - lastBackgroundTime) / 1000; // Convert to seconds
    final timeout = await getLockTimeout();

    print(
      '⏱️ Time since background: ${timeSinceBackground.toStringAsFixed(1)}s, timeout: ${timeout}s',
    );

    return timeSinceBackground >= timeout;
  }

  /// Clear background time (call after successful unlock)
  static Future<void> clearBackgroundTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastBackgroundTime);
    // Mark that user has unlocked this session
    _hasUnlockedThisSession = true;
    print('✅ Background time cleared - session unlocked');
  }

  /// Check if user has already unlocked during this app session
  static bool hasUnlockedThisSession() {
    return _hasUnlockedThisSession;
  }

  /// Reset session unlock flag (call when app goes to background)
  static void resetSessionUnlock() {
    _hasUnlockedThisSession = false;
    print('🔄 Session unlock flag reset');
  }
}
