import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/app_lock_service.dart';
import '../data/services/storage_service.dart';
import '../modules/app_lock/app_lock_page.dart';

/// Manages app lifecycle and triggers app lock when needed
class AppLifecycleManager extends WidgetsBindingObserver {
  bool _isLocked = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('📱 App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _handleAppPaused() async {
    print('📱 App paused/inactive');

    // Check if app lock is enabled
    final lockEnabled = await AppLockService.isAppLockEnabled();

    if (lockEnabled) {
      // Record the time app went to background
      await AppLockService.recordBackgroundTime();
      // Reset the session unlock flag so user needs to unlock again next time
      AppLockService.resetSessionUnlock();
      print('🔐 App lock enabled - background time recorded, session reset');
    }
  }

  Future<void> _handleAppResumed() async {
    print('📱 App resumed');

    // Prevent showing lock screen multiple times
    if (_isLocked) {
      print('⚠️ Lock screen already showing');
      return;
    }

    // Check if app lock is enabled
    final lockEnabled = await AppLockService.isAppLockEnabled();

    if (!lockEnabled) {
      print('🔓 App lock not enabled');
      return;
    }

    // Check if user is logged in
    final isLoggedIn = await StorageService.isLoggedIn();

    if (!isLoggedIn) {
      print('👤 User not logged in, skipping app lock');
      return;
    }

    // Check if enough time has passed to lock the app
    final shouldLock = await AppLockService.shouldLockApp();

    if (shouldLock) {
      print('🔐 App should be locked - showing lock screen');
      _showLockScreen();
    } else {
      print('✅ App does not need to be locked yet');
      await AppLockService.clearBackgroundTime();
    }
  }

  Future<void> _showLockScreen() async {
    if (_isLocked) return;

    _isLocked = true;

    try {
      // Show lock screen as a fullscreen dialog
      final result = await Get.dialog<bool>(
        const AppLockPage(),
        barrierDismissible: false,
        barrierColor: Colors.white,
      );

      if (result == true) {
        print('✅ App unlocked successfully');
      }
    } finally {
      _isLocked = false;
    }
  }

  /// Manually trigger lock screen (for testing or manual lock)
  Future<void> lockApp() async {
    final lockEnabled = await AppLockService.isAppLockEnabled();

    if (lockEnabled) {
      await AppLockService.recordBackgroundTime();
      _showLockScreen();
    }
  }
}
