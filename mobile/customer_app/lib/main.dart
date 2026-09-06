import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_config.dart';
import 'config/dependency_injection.dart';
import 'config/routes_config.dart';
import 'config/theme_config.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await setupDependencyInjection()
        .timeout(const Duration(seconds: 10));

    await getIt<AuthController>()
        .restoreSession()
        .timeout(const Duration(seconds: 10));
  } catch (e, stackTrace) {
    debugPrint('Application startup error: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Use the customer-facing wrapper so this app can be referenced as CustomerApp
  runApp(const CustomerApp());
}

/// Customer-facing wrapper (keeps the existing VendorHubApp class intact).
/// This allows tests and other callers to use `CustomerApp` while preserving
/// any existing references to `VendorHubApp` elsewhere.
class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // VendorHubApp has a const constructor, so we can return it here.
    return const VendorHubApp();
  }
}

/// Backwards-compatible alias for callers/tests that expect `MyApp`.
/// Add this small wrapper so references like `const MyApp()` compile.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const VendorHubApp();
  }
}

class VendorHubApp extends StatelessWidget {
  const VendorHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.APP_NAME,
      debugShowCheckedModeBanner: AppConfig.DEBUG_MODE,
      theme: AppTheme.light(),
      darkTheme: AppConfig.FEATURE_DARK_MODE ? AppTheme.dark() : null,
      themeMode: ThemeMode.system,
      routerConfig: AppRoutes.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
    );
  }
}
