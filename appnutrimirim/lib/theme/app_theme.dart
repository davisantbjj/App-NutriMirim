import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light({bool highContrast = false}) {
    final p = highContrast ? AppPalette.altoContraste : AppPalette.normal;
    final textColor = p.texto;
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Almarai',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.green,
        error:
            AppColors.statusBadText, // texto de erro AA; borda segue vermelha
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: p.fundo,
      extensions: [p],
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.fundo,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.superficie,
        hintStyle: TextStyle(color: p.textoSecundario, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 48,
        ),
        border: _outline(p.borda),
        enabledBorder: _outline(p.borda),
        focusedBorder: _outline(AppColors.primary, width: 1.6),
        errorBorder: _outline(AppColors.red),
        focusedErrorBorder: _outline(AppColors.red, width: 1.6),
        prefixIconColor: p.icone,
        suffixIconColor: p.textoSecundario,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : p.borda,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: color, width: width),
      );
}
