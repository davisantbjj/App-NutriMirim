import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Projeto Firebase "app-nutrimirim" (gerado pelo `flutterfire configure`).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Os dados vêm de `Repositorios` (lib/repositories/repositorios.dart), que por
  // padrão usa a memória com o mock. Depois do login (AuthService), chame
  // `Repositorios.usarFirestore(sessao)`; ao sair, `Repositorios.reiniciar()`.
  authService = FirebaseAuthService();
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
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        initialRoute: Routes.splash,
        routes: Routes.table,
      ),
    );
  }
}
