import 'dart:io';

import 'package:flutter/services.dart';

Future<void> _fonte(String familia, List<String> arquivos) async {
  final l = FontLoader(familia);
  for (final a in arquivos) {
    final bytes = await File('assets/fonts/$a').readAsBytes();
    l.addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await l.load();
}

/// Carrega as fontes reais do app (em testes o padrão é Ahem, mais larga).
Future<void> carregarFontes() async {
  await _fonte('Almarai', [
    'Almarai-Regular.ttf',
    'Almarai-Bold.ttf',
    'Almarai-ExtraBold.ttf',
  ]);
  await _fonte('BagelFatOne', ['BagelFatOne-Regular.ttf']);
}
