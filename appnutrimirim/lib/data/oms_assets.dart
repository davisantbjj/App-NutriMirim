import 'package:flutter/services.dart';
import '../services/antropometria_oms.dart';

Future<TabelasOms>? _cache;

/// Apenas esta camada conhece os assets Flutter; cálculo é Dart puro.
Future<TabelasOms> carregarTabelasOms() => _cache ??= _carregar();

Future<TabelasOms> _carregar() async {
  try {
    final textos = await Future.wait([
      for (final nome in [
        'weianthro',
        'lenanthro',
        'wflanthro',
        'wfhanthro',
        'bmianthro',
      ])
        rootBundle.loadString('assets/oms/$nome.txt'),
    ]);
    return TabelasOms(
      pesoIdade: textos[0],
      alturaIdade: textos[1],
      pesoComprimento: textos[2],
      pesoAltura: textos[3],
      imcIdade: textos[4],
    );
  } catch (_) {
    _cache = null;
    rethrow;
  }
}
