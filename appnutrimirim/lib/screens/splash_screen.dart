import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../theme/app_palette.dart';
import '../widgets/common.dart';

/// TELA 01 — Abertura (splash).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), _goToLogin);
  }

  Future<void> _goToLogin() async {
    _timer?.cancel();
    // Quem já entrou antes continua logado e vai direto para o Início.
    // Se a sessão não puder ser lida, segue para o Login.
    UsuarioLogado? usuario;
    try {
      usuario = await authService.restaurarSessao();
    } catch (_) {
      usuario = null;
    }
    // Com sessão salva, lê o perfil e liga o Firestore antes do Início. Sem
    // acesso ou sem perfil, vai para o Login com a mensagem.
    String? erro;
    if (usuario != null) {
      try {
        await iniciarSessao(usuario);
      } on AuthException catch (e) {
        usuario = null;
        erro = e.mensagem;
      }
    }
    // Só sai da abertura se ela estiver visível (evita redirecionar quando o
    // app foi aberto direto em outra rota, por exemplo um link na web).
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    final mensagens = ScaffoldMessenger.of(context);
    Navigator.pushReplacementNamed(
      context,
      usuario == null ? Routes.login : Routes.home,
    );
    if (erro != null) mensagens.showSnackBar(SnackBar(content: Text(erro)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _goToLogin,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: CustomPaint(painter: _WavesPainter())),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const AppLogo(size: 230, withName: true),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'A trena digital que mede o futuro\ndas crianças brasileiras!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.cores.textoSecundario,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Spacer(flex: 5),
                  Text(
                    'Monitoramento Nutricional Infantil',
                    style: TextStyle(
                      color: context.cores.textoSecundario.withValues(
                        alpha: .9,
                      ),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formas orgânicas (verde, verde-água e azul-claro) no rodapé da abertura.
class _WavesPainter extends CustomPainter {
  const _WavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final blue = Path()
      ..moveTo(0, h * .80)
      ..quadraticBezierTo(w * .5, h * .86, w, h * .77)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(blue, Paint()..color = const Color(0xFFBEE6F8));

    final green = RRect.fromRectAndRadius(
      Rect.fromLTWH(-w * .25, h * .64, w * .78, h * .2),
      Radius.circular(w * .2),
    );
    canvas.save();
    canvas.translate(0, 0);
    canvas.rotate(.04);
    canvas.drawRRect(green, Paint()..color = const Color(0xFFB9E6BC));
    canvas.restore();

    final teal = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * .42, h * .59, w * .75, h * .2),
      Radius.circular(w * .2),
    );
    canvas.save();
    canvas.rotate(-.05);
    canvas.drawRRect(teal, Paint()..color = const Color(0xFFA8DFD6));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
