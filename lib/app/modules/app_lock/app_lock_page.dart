import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/app_lock_service.dart';
import '../../data/services/biometric_service.dart';

class AppLockController extends GetxController {
  final BiometricService _biometricService = BiometricService();

  final isAuthenticating = false.obs;
  final authenticationFailed = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Auto-trigger authentication when screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      authenticate();
    });
  }

  Future<void> authenticate() async {
    if (isAuthenticating.value) return;

    try {
      isAuthenticating.value = true;
      authenticationFailed.value = false;
      errorMessage.value = '';

      print('🔐 Starting app lock authentication...');

      final authenticated = await _biometricService.authenticateForAppLock();

      if (authenticated) {
        print('✅ App lock authentication successful');
        await AppLockService.clearBackgroundTime();
        // Close the lock screen and return to app
        Get.back(result: true);
      } else {
        print('❌ App lock authentication failed');
        authenticationFailed.value = true;
        errorMessage.value = 'Authentication failed. Please try again.';
      }
    } catch (e) {
      print('❌ App lock authentication error: $e');
      authenticationFailed.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isAuthenticating.value = false;
    }
  }

  void retry() {
    authenticate();
  }
}

class AppLockPage extends StatelessWidget {
  const AppLockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppLockController());

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Obx(
            () => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 60,
                        color: Colors.blue.shade700,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'AT-EASE Fleet Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'App is locked',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Authentication Status
                    if (controller.isAuthenticating.value)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Authenticating...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                    else if (controller.authenticationFailed.value)
                      Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: controller.retry,
                            icon: const Icon(Icons.lock_open),
                            label: const Text('Unlock'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Initial state - waiting for biometric prompt
                      Column(
                        children: [
                          Icon(
                            Icons.fingerprint,
                            size: 64,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unlock to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 48),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How to unlock:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInstruction('• Use your fingerprint or face'),
                          _buildInstruction(
                            '• Or enter your device PIN/password',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),
    );
  }
}
