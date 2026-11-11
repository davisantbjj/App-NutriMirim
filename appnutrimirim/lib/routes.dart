import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/recuperar_email_screen.dart';
import 'screens/auth/recuperar_enviado_screen.dart';
import 'screens/auth/recuperar_nova_senha_screen.dart';
import 'screens/avaliacao/cadastro_crianca_screen.dart';
import 'screens/avaliacao/nova_avaliacao_screen.dart';
import 'screens/avaliacao/registro_medidas_screen.dart';
import 'screens/avaliacao/resultado_screen.dart';
import 'screens/crianca/curva_crescimento_screen.dart';
import 'screens/crianca/dados_crianca_screen.dart';
import 'screens/crianca/lista_criancas_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/splash_screen.dart';

/// Nomes de rota de todas as telas do protótipo (01 a 12).
class Routes {
  Routes._();

  static const splash = '/'; // 01
  static const login = '/login'; // 02
  static const recuperarEmail = '/recuperar'; // 02A
  static const recuperarEnviado = '/recuperar/enviado'; // 02B
  static const recuperarNovaSenha = '/recuperar/nova-senha'; // 02C
  static const home = '/inicio'; // 03
  static const novaAvaliacao = '/avaliacao'; // 04
  static const cadastroCrianca = '/avaliacao/cadastro'; // 05
  static const registroMedidas = '/avaliacao/medidas'; // 06
  static const resultado = '/avaliacao/resultado'; // 07
  static const curvaCrescimento = '/crianca/curva'; // 08
  static const historico = '/historico'; // 09
  static const dadosCrianca = '/crianca'; // 10
  static const perfil = '/perfil'; // 11
  static const listaCriancas = '/criancas'; // 12

  static final Map<String, WidgetBuilder> table = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    recuperarEmail: (_) => const RecuperarEmailScreen(),
    recuperarEnviado: (_) => const RecuperarEnviadoScreen(),
    recuperarNovaSenha: (_) => const RecuperarNovaSenhaScreen(),
    home: (_) => const HomeScreen(),
    novaAvaliacao: (_) => const NovaAvaliacaoScreen(),
    cadastroCrianca: (_) => const CadastroCriancaScreen(),
    registroMedidas: (_) => const RegistroMedidasScreen(),
    resultado: (_) => const ResultadoScreen(),
    curvaCrescimento: (_) => const CurvaCrescimentoScreen(),
    historico: (_) => const HistoricoScreen(),
    dadosCrianca: (_) => const DadosCriancaScreen(),
    perfil: (_) => const PerfilScreen(),
    listaCriancas: (_) => const ListaCriancasScreen(),
  };
}
