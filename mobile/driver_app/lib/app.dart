import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_config.dart';
import 'config/dependency_injection.dart';
import 'config/theme_config.dart';
import 'core/router/app_routes.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/deliveries/presentation/pages/delivery_detail_page.dart';
import 'features/home/presentation/pages/driver_home_shell.dart';

class VendorHubDriverApp extends StatelessWidget {
  const VendorHubDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.APP_NAME,
      debugShowCheckedModeBanner: false,
      theme: DriverAppTheme.light(),
      darkTheme: AppConfig.FEATURE_DARK_MODE ? DriverAppTheme.dark() : null,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.root,
      getPages: [
        GetPage(name: AppRoutes.root, page: () => const AuthGate()),
        GetPage(name: AppRoutes.login, page: () => const LoginPage()),
        GetPage(name: AppRoutes.home, page: () => const DriverHomeShell()),
        GetPage(
          name: '${AppRoutes.deliveryDetail}/:id',
          page: () => DeliveryDetailPage(deliveryId: Get.parameters['id'] ?? ''),
        ),
      ],
    );
  }
}

/// Decides the first screen based on the restored auth session.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthController _auth = getIt<AuthController>();

  @override
  void initState() {
    super.initState();
    _auth.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = _auth.status.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (status == AuthStatus.authenticated && _auth.user.value != null) {
          Get.offAllNamed(AppRoutes.home);
        } else if (status == AuthStatus.unauthenticated) {
          Get.offAllNamed(AppRoutes.login);
        }
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    });
  }
}
