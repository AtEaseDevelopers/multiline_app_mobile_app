import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../core/values/app_strings.dart';
import 'auth_controller.dart';

class LoginPage extends StatefulWidget {
  final String role; // driver or supervisor
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.put(AuthController());
  bool rememberMe = false; // Default to false when biometric is available
  bool enableBiometricAfterLogin = false;
  bool _isLoadingBiometricState = true; // Track loading state
  bool _isBiometricEnabledForThisRole = false; // Cache the result

  @override
  void initState() {
    super.initState();
    // Load biometric state BEFORE showing UI
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    // Check if biometric is enabled for THIS specific role
    final isBiometricForThisRole = await _authController
        .isBiometricEnabledForRole(widget.role);

    setState(() {
      _isBiometricEnabledForThisRole = isBiometricForThisRole;
      _isLoadingBiometricState = false;
    });

    // If biometric is enabled, trigger it automatically
    if (isBiometricForThisRole && _authController.isBiometricAvailable.value) {
      // Small delay to ensure UI is rendered
      await Future.delayed(const Duration(milliseconds: 300));
      _handleBiometricLogin();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      await _authController.login(
        email,
        password,
        widget.role,
        rememberMe: enableBiometricAfterLogin ? false : rememberMe,
      );

      // If login successful and user wants to enable biometric
      if (_authController.currentUser.value != null &&
          enableBiometricAfterLogin) {
        await _authController.enableBiometric(
          email: email,
          password: password,
          userType: widget.role,
        );
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    // Use device lock login (supports fingerprint/face/PIN/password/pattern)
    await _authController.loginWithDeviceLock();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking biometric state
    if (_isLoadingBiometricState) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Icon(
                  widget.role == 'driver'
                      ? Icons.local_shipping
                      : Icons.admin_panel_settings,
                  size: 56,
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    widget.role == 'driver'
                        ? '${SKeys.driver.tr} ${SKeys.login.tr}'
                        : '${SKeys.supervisor.tr} ${SKeys.login.tr}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                // Show biometric login button at TOP if enabled for this role
                Obx(
                  () =>
                      _authController.isBiometricAvailable.value &&
                          _isBiometricEnabledForThisRole
                      ? Column(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _authController.isLoading.value
                                  ? null
                                  : _handleBiometricLogin,
                              icon: const Icon(Icons.lock_open, size: 32),
                              label: Text(
                                SKeys.biometricLogin.tr,
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('OR'),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                CustomTextField(
                  label: SKeys.emailOrId.tr,
                  hint: SKeys.emailOrIdHint.tr,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or ID or phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: SKeys.password.tr,
                  hint: SKeys.passwordHint.tr,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Show Remember Me only if biometric is NOT enabled for this role
                !_isBiometricEnabledForThisRole
                    ? Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (v) {
                              final shouldEnable = v ?? false;

                              // Check if trying to enable while biometric is selected
                              if (shouldEnable && enableBiometricAfterLogin) {
                                Get.snackbar(
                                  'Cannot Enable Both',
                                  'Please disable Quick Login first. You can only use one login method at a time.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                  margin: const EdgeInsets.all(16),
                                );
                                return;
                              }

                              setState(() => rememberMe = shouldEnable);
                            },
                          ),
                          Expanded(child: Text(SKeys.rememberMe.tr)),
                        ],
                      )
                    : const SizedBox.shrink(),
                // Show enable biometric option if available and not already enabled for this role
                Obx(
                  () =>
                      _authController.isBiometricAvailable.value &&
                          !_isBiometricEnabledForThisRole
                      ? Row(
                          children: [
                            Checkbox(
                              value: enableBiometricAfterLogin,
                              onChanged: (v) {
                                final shouldEnable = v ?? false;

                                // Check if trying to enable while remember me is selected
                                if (shouldEnable && rememberMe) {
                                  Get.snackbar(
                                    'Cannot Enable Both',
                                    'Please disable Remember Me first. You can only use one login method at a time.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                    ),
                                    margin: const EdgeInsets.all(16),
                                  );
                                  return;
                                }

                                setState(() {
                                  enableBiometricAfterLogin = shouldEnable;
                                  // Auto-disable remember me when enabling biometric
                                  if (shouldEnable) {
                                    rememberMe = false;
                                  }
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Enable Quick Login (Fingerprint/PIN)',
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => PrimaryButton(
                    text: SKeys.login.tr,
                    fullWidth: true,
                    isLoading: _authController.isLoading.value,
                    onPressed: _authController.isLoading.value
                        ? null
                        : _handleLogin,
                  ),
                ),
                const SizedBox(height: 12),
                // Center(
                //   child: TextButton(
                //     onPressed: () {},
                //     child: Text(SKeys.forgotPassword.tr),
                //   ),
                // ),
                // Show disable biometric option if biometric is enabled for this role
                _isBiometricEnabledForThisRole
                    ? Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            await _authController.disableBiometric();
                            // Reload biometric state
                            await _loadBiometricState();
                          },
                          icon: const Icon(Icons.fingerprint_outlined),
                          label: const Text('Disable Biometric Login'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
