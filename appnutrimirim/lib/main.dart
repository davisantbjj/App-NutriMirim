import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'services/sessao_service_firestore.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Projeto Firebase "app-nutrimirim" (gerado pelo `flutterfire configure`).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Os dados vêm de `Repositorios` (lib/repositories/repositorios.dart), que
  // começa na memória. Depois do login, `iniciarSessao` (app_state.dart) lê
  // `profissionais/{uid}` e liga o Firestore; ao sair, `desligarSessao` volta
  // à memória e apaga o cache.
  authService = FirebaseAuthService();
  sessaoService = SessaoServiceFirestore();
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
