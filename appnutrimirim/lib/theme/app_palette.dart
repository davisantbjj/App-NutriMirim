import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Cores que mudam com o "Alto Contraste" (Perfil > Preferências).
///
/// Nas telas, use `context.cores.texto`, `context.cores.borda` etc. no lugar
/// de `AppColors`. As cores de marca e de status continuam em `AppColors`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ehAltoContraste,
    required this.texto,
    required this.textoSecundario,
    required this.borda,
    required this.bordaSuave,
    required this.icone,
    required this.fundo,
    required this.superficie,
  });

  /// Verdadeiro na paleta de alto contraste, para ajustes pontuais.
  final bool ehAltoContraste;

  /// Títulos e texto principal.
  final Color texto;

  /// Rótulos, legendas e exemplos (hint) dos campos.
  final Color textoSecundario;

  /// Borda de campos e controles (no mínimo 3:1 sobre o fundo).
  final Color borda;

  /// Borda de cartões e divisórias (decorativa).
  final Color bordaSuave;

  /// Ícones neutros e borda da barra inferior.
  final Color icone;

  /// Fundo das telas.
  final Color fundo;

  /// Fundo de cartões e campos.
  final Color superficie;

  static const normal = AppPalette(
    ehAltoContraste: false,
    texto: AppColors.textDark,
    textoSecundario: AppColors.textMuted,
    borda: AppColors.borderStrong,
    bordaSuave: AppColors.border,
    icone: AppColors.iconMuted,
    fundo: AppColors.background,
    superficie: AppColors.surface,
  );

  static const altoContraste = AppPalette(
    ehAltoContraste: true,
    texto: Colors.black,
    textoSecundario: AppColors.textDark,
    borda: AppColors.textDark,
    bordaSuave: AppColors.iconMuted,
    icone: AppColors.textDark,
    fundo: Colors.white,
    superficie: Colors.white,
  );

  @override
  AppPalette copyWith({
    bool? ehAltoContraste,
    Color? texto,
    Color? textoSecundario,
    Color? borda,
    Color? bordaSuave,
    Color? icone,
    Color? fundo,
    Color? superficie,
  }) {
    return AppPalette(
      ehAltoContraste: ehAltoContraste ?? this.ehAltoContraste,
      texto: texto ?? this.texto,
      textoSecundario: textoSecundario ?? this.textoSecundario,
      borda: borda ?? this.borda,
      bordaSuave: bordaSuave ?? this.bordaSuave,
      icone: icone ?? this.icone,
      fundo: fundo ?? this.fundo,
      superficie: superficie ?? this.superficie,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      ehAltoContraste: t < 0.5 ? ehAltoContraste : other.ehAltoContraste,
      texto: Color.lerp(texto, other.texto, t)!,
      textoSecundario: Color.lerp(textoSecundario, other.textoSecundario, t)!,
      borda: Color.lerp(borda, other.borda, t)!,
      bordaSuave: Color.lerp(bordaSuave, other.bordaSuave, t)!,
      icone: Color.lerp(icone, other.icone, t)!,
      fundo: Color.lerp(fundo, other.fundo, t)!,
      superficie: Color.lerp(superficie, other.superficie, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Paleta do tema atual (normal ou alto contraste).
  AppPalette get cores =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.normal;
}
