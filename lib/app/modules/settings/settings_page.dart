import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/app_lock_service.dart';
import '../../data/services/biometric_service.dart';
import '../../data/services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAppLockEnabled = false;
  bool _isRememberMeEnabled = false;
  bool _isQuickLoginEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final appLockEnabled = await AppLockService.isAppLockEnabled();
    final rememberMe = await StorageService.getRememberMe();
    final quickLogin = await StorageService.getBiometricEnabled();

    setState(() {
      _isAppLockEnabled = appLockEnabled;
      _isRememberMeEnabled = rememberMe;
      _isQuickLoginEnabled = quickLogin;
      _isLoading = false;
    });
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      // Enabling app lock - test authentication first
      final biometricService = BiometricService();

      try {
        final authenticated = await biometricService.authenticateForAppLock();

        if (authenticated) {
          await AppLockService.setAppLockEnabled(true);
          setState(() {
            _isAppLockEnabled = true;
          });

          Get.snackbar(
            'App Lock Enabled',
            'Your app is now protected with device lock',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          );
        } else {
          Get.snackbar(
            'Authentication Failed',
            'Please try again',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(Icons.error, color: Colors.white),
            margin: const EdgeInsets.all(16),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not enable app lock: ${e.toString().replaceAll('Exception: ', '')}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.warning, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      }
    } else {
      // Disabling app lock
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_open, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Text('Disable App Lock?'),
            ],
          ),
          content: const Text(
            'Your app will no longer require authentication when opening.',
            style: TextStyle(fontSize: 15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await AppLockService.setAppLockEnabled(false);
        setState(() {
          _isAppLockEnabled = false;
        });

        Get.snackbar(
          'App Lock Disabled',
          'Your app is no longer protected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[700]!,
          colorText: Colors.white,
          icon: const Icon(Icons.lock_open, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  Future<void> _toggleRememberMe(bool value) async {
    if (!value) {
      // Disabling remember me
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Text('Disable Remember Me?'),
            ],
          ),
          content: const Text(
            'You will need to login again next time you open the app.',
            style: TextStyle(fontSize: 15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await StorageService.clearRememberMe();
        setState(() {
          _isRememberMeEnabled = false;
        });

        Get.snackbar(
          'Remember Me Disabled',
          'You will need to login next time',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[700]!,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  Future<void> _toggleQuickLogin(bool value) async {
    if (!value) {
      // Disabling quick login
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Text('Disable Quick Login?'),
            ],
          ),
          content: const Text(
            'You will need to enter your password to login next time.',
            style: TextStyle(fontSize: 15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await StorageService.clearBiometricData();
        setState(() {
          _isQuickLoginEnabled = false;
        });

        Get.snackbar(
          'Quick Login Disabled',
          'You will need to enter password next time',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[700]!,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.brandBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Security Section Title
                  Text(
                    'Security & Privacy',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Lock Setting
                  _ModernSettingCard(
                    icon: Icons.lock,
                    title: 'App Lock',
                    subtitle: _isAppLockEnabled
                        ? 'Enabled - App requires unlock'
                        : 'Disabled - No protection',
                    isEnabled: _isAppLockEnabled,
                    onChanged: _toggleAppLock,
                    activeColor: Colors.green,
                  ),
                  const SizedBox(height: 12),

                  // Quick Login Setting
                  _ModernSettingCard(
                    icon: Icons.fingerprint,
                    title: 'Quick Login',
                    subtitle: _isQuickLoginEnabled
                        ? 'Use device lock to login'
                        : 'Configure during login',
                    isEnabled: _isQuickLoginEnabled,
                    onChanged: _isQuickLoginEnabled ? _toggleQuickLogin : null,
                    activeColor: Colors.blue,
                    showInfoOnly: !_isQuickLoginEnabled,
                  ),
                  const SizedBox(height: 12),

                  // Remember Me Setting
                  _ModernSettingCard(
                    icon: Icons.bookmark,
                    title: 'Remember Me',
                    subtitle: _isRememberMeEnabled
                        ? 'Stay logged in'
                        : 'Configure during login',
                    isEnabled: _isRememberMeEnabled,
                    onChanged: _isRememberMeEnabled ? _toggleRememberMe : null,
                    activeColor: Colors.purple,
                    showInfoOnly: !_isRememberMeEnabled,
                  ),

                  const SizedBox(height: 32),

                  // Information Section
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade50,
                          Colors.blue.shade100.withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Settings Guide',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoTip(
                          icon: Icons.lock,
                          text:
                              'App Lock requires authentication when opening app',
                        ),
                        const SizedBox(height: 12),
                        _InfoTip(
                          icon: Icons.fingerprint,
                          text:
                              'Quick Login uses fingerprint/PIN instead of password',
                        ),
                        const SizedBox(height: 12),
                        _InfoTip(
                          icon: Icons.bookmark,
                          text: 'Remember Me keeps you logged in',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.amber.shade800,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Quick Login & Remember Me are set during login',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add bottom padding for device navigation buttons
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Modern Setting Card Widget
class _ModernSettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final Function(bool)? onChanged;
  final Color activeColor;
  final bool showInfoOnly;

  const _ModernSettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    this.onChanged,
    this.activeColor = Colors.blue,
    this.showInfoOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEnabled
                    ? [
                        activeColor.withValues(alpha: 0.1),
                        activeColor.withValues(alpha: 0.05),
                      ]
                    : [
                        Colors.grey.withValues(alpha: 0.1),
                        Colors.grey.withValues(alpha: 0.05),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isEnabled ? activeColor : Colors.grey[600],
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Label and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isEnabled
                        ? activeColor
                        : theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Toggle Switch or Info Icon
          if (showInfoOnly)
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.iconTheme.color?.withValues(alpha: 0.5),
            )
          else if (onChanged != null)
            Switch(
              value: isEnabled,
              onChanged: onChanged,
              activeTrackColor: activeColor.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return activeColor;
                }
                return null;
              }),
            ),
        ],
      ),
    );
  }
}

// Info Tip Widget
class _InfoTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.shade700.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade900,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
