import 'package:flutter/material.dart';

import 'app_state.dart';
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

  /// Rotas que abrem sem login. As outras exigem `authService.atual`.
  static const publicas = {
    splash,
    login,
    recuperarEmail,
    recuperarEnviado,
    recuperarNovaSenha,
  };

  /// `onGenerateRoute` do app: rota protegida sem login abre o Login.
  /// Rota desconhecida devolve `null` (erro do Navigator, como antes).
  static Route<dynamic>? gerar(RouteSettings settings) {
    final nome = settings.name;
    final builder = table[nome];
    if (builder == null) return null;
    if (!publicas.contains(nome) && authService.atual == null) {
      return MaterialPageRoute(
        builder: table[login]!,
        settings: const RouteSettings(name: login),
      );
    }
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  /// `onGenerateInitialRoutes` do app. Na web, o endereço digitado vira a
  /// rota inicial: `/inicio`, `/perfil` etc. abertos direto passam pela
  /// Abertura, que restaura a sessão e liga os repositórios antes de seguir
  /// para o Início ou o Login. Login e recuperação de senha abrem direto.
  static List<Route<dynamic>> gerarIniciais(String inicial) {
    final nome = publicas.contains(inicial) ? inicial : splash;
    return [
      MaterialPageRoute(
        builder: table[nome]!,
        settings: RouteSettings(name: nome),
      ),
    ];
  }
}
