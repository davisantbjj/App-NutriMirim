import 'package:flutter/material.dart';

import 'app_state.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NutriMirimApp());
}

class NutriMirimApp extends StatelessWidget {
  const NutriMirimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: highContrast,
      builder: (context, hc, _) => MaterialApp(
        title: 'NutriMirim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(highContrast: hc),
        initialRoute: Routes.splash,
        routes: Routes.table,
      ),
    );
  }
}
