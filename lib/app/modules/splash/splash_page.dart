import 'package:flutter/material.dart';
import '../../core/values/app_constants.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/app_lock_service.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: AppConstants.splashMinMs), () {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Check if app lock is enabled FIRST
      final isAppLockEnabled = await AppLockService.isAppLockEnabled();

      // Only show app lock if:
      // 1. App lock is enabled
      // 2. User hasn't unlocked during this session yet
      if (isAppLockEnabled && !AppLockService.hasUnlockedThisSession()) {
        // App lock is enabled - navigate to app lock screen
        // After successful unlock, it will return here and we'll continue
        final unlocked = await Get.toNamed(AppRoutes.appLock);

        if (unlocked != true) {
          // User failed to unlock or cancelled - stay on splash or exit
          return;
        }
      }

      // Continue with normal auth flow after unlock (or if app lock disabled)
      final isLoggedIn = await StorageService.isLoggedIn();
      final rememberMe = await StorageService.getRememberMe();

      if (isLoggedIn && rememberMe) {
        // User is already logged in with remember me - go to dashboard
        final userType = await StorageService.getUserType();

        if (userType == 'driver') {
          Get.offAllNamed(AppRoutes.driverDashboard);
        } else if (userType == 'supervisor') {
          Get.offAllNamed(AppRoutes.supervisorDashboard);
        } else {
          Get.offAllNamed(AppRoutes.roleSelection);
        }
      } else if (!isLoggedIn && rememberMe) {
        // User is logged out but remember me is enabled - auto login
        final credentials = await StorageService.getRememberMeCredentials();

        if (credentials != null) {
          // Import auth_controller at the top if not already imported
          final authController = Get.put(AuthController());

          try {
            // Auto-login with saved credentials
            await authController.login(
              credentials['email']!,
              credentials['password']!,
              credentials['userType']!,
              rememberMe: true,
            );
            // Navigation is handled in the login method
          } catch (e) {
            // Auto-login failed, go to role selection
            Get.offAllNamed(AppRoutes.roleSelection);
          }
        } else {
          // No credentials saved, go to role selection
          Get.offAllNamed(AppRoutes.roleSelection);
        }
      } else {
        // Always navigate to role selection after logout or first launch
        // User will select their role, and biometric will auto-trigger if enabled
        Get.offAllNamed(AppRoutes.roleSelection);
      }
    } catch (e) {
      // If any error occurs, go to role selection
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'AT-EASE Fleet Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text('v1.0.0', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
