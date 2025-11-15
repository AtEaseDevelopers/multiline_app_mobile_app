import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/translations/app_translations.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/app_lifecycle_manager.dart';
import 'app/data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize app lifecycle manager for app lock
  final lifecycleManager = AppLifecycleManager();
  WidgetsBinding.instance.addObserver(lifecycleManager);

  // Load saved locale
  final savedLocale = await StorageService.getLocale();
  Locale initialLocale = const Locale('en', 'US');
  if (savedLocale != null) {
    final parts = savedLocale.split('_');
    if (parts.length == 2) {
      initialLocale = Locale(parts[0], parts[1]);
    }
  }

  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AT-EASE Fleet Management',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // Force light theme (disable dark mode)
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      debugShowCheckedModeBanner: false,
    );
  }
}
