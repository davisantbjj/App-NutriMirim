import 'package:appnutrimirim/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todas as plataformas apontam para o projeto app-nutrimirim', () {
    for (final opcoes in [
      DefaultFirebaseOptions.android,
      DefaultFirebaseOptions.ios,
      DefaultFirebaseOptions.web,
    ]) {
      expect(opcoes.projectId, 'app-nutrimirim');
      expect(opcoes.appId, isNotEmpty);
      expect(opcoes.apiKey, isNotEmpty);
    }
  });

  test('o app Android usa o pacote do NutriMirim', () {
    expect(DefaultFirebaseOptions.android.appId, contains(':android:'));
    expect(
      DefaultFirebaseOptions.ios.iosBundleId,
      'br.com.nutrimirim.appnutrimirim',
    );
  });
}
