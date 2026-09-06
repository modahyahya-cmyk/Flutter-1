import 'package:flutter/material.dart';

import 'app.dart';
import 'config/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const VendorHubDriverApp());
}
