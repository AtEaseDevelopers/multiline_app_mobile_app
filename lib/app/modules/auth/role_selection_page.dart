import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../core/values/app_strings.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget roleCard({
      required String title,
      required String desc,
      required String emoji,
      required VoidCallback onTap,
    }) {
      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(desc, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.local_shipping, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  SKeys.selectYourRole.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 24),
              roleCard(
                title: SKeys.driver.tr.toUpperCase(),
                desc: SKeys.driverDesc.tr,
                emoji: '🚚',
                onTap: () => Get.toNamed(
                  AppRoutes.login,
                  parameters: {'role': 'driver'},
                ),
              ),
              const SizedBox(height: 12),
              roleCard(
                title: SKeys.supervisor.tr.toUpperCase(),
                desc: SKeys.supervisorDesc.tr,
                emoji: '👥',
                onTap: () => Get.toNamed(
                  AppRoutes.login,
                  parameters: {'role': 'supervisor'},
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Get.updateLocale(const Locale('en', 'US')),
                    child: const Text('EN'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Get.updateLocale(const Locale('ms', 'MY')),
                    child: const Text('BM'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
