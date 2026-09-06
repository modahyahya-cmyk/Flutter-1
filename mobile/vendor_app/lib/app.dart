import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/dependency_injection.dart';
import 'config/theme_config.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

class VendorHubVendorApp extends StatefulWidget {
  const VendorHubVendorApp({super.key});

  @override
  State<VendorHubVendorApp> createState() => _VendorHubVendorAppState();
}

class _VendorHubVendorAppState extends State<VendorHubVendorApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = locator<AuthController>();
    // Restore any persisted session (token + cached user) on cold start.
    _authController.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: VendorAppTheme.light(),
      darkTheme: AppConfig.FEATURE_DARK_MODE ? VendorAppTheme.dark() : null,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
