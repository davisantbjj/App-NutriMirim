import 'package:flutter/foundation.dart';

import 'services/auth_service.dart';
import 'services/auth_service_memoria.dart';

/// Preferência global de alto contraste (Perfil Profissional > Preferências).
final highContrast = ValueNotifier<bool>(false);

/// Serviço de autenticação usado pelas telas.
///
/// O `main.dart` troca pelo `FirebaseAuthService`. Nos testes fica a versão
/// em memória, sem Firebase; para simular contas, atribua outra
/// `AuthServiceMemoria(contas: {...})`.
AuthService authService = AuthServiceMemoria();
