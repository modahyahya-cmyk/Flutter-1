import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';

/// Lightweight starting screen shown only while the auth state is being
/// resolved. The router's [GoRouter.redirect] moves the user on as soon as
/// [AuthController.status] leaves the loading/initial state.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConfig.APP_NAME,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
