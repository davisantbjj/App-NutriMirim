import 'package:flutter/material.dart';

/// Paleta extraída do arquivo Figma "NutriMirim — Protótipo de Alta Fidelidade".
class AppColors {
  AppColors._();

  // Marca
  static const primary = Color(0xFF0A6BC1); // azul dos botões principais
  static const primaryLight = Color(0xFF2194DB);
  static const green = Color(0xFF0F9E5E);
  static const orange = Color(0xFFF48C19);
  static const red = Color(0xFFFF4D4D);

  // Texto
  static const textBody = Color(0xFF213041); // corpo/rótulos secundários
  /// Cinza-azulado um pouco mais escuro, para texto pequeno sobre cartões tingidos (AA).
  static const textMutedOnTint = Color(0xFF4A6079);
  static const wordmarkBlue = Color(0xFF103F6E);
  static const textDark = Color(0xFF051F38);
  static const textMuted = Color(0xFF59708C);
  static const textHint = Color(0xFF7A8798);

  // Superfícies
  static const background = Color(0xFFFBFCFF);
  static const surface = Colors.white;
  static const iconMuted = Color(
    0xFF3F657D,
  ); // ícones e borda da barra inferior
  static const successBorder = Color(0xFF7BDEAC);
  static const border = Color(0xFFCCE0F2);

  // Fundos suaves dos cartões
  static const lightSky = Color(0xFFE8F7FF);
  static const lightBlue = Color(0xFFE0F2FF);
  static const lightGreen = Color(0xFFDBF5E8);
  static const lightMint = Color(
    0xFFE0F7ED,
  ); // cartões verdes (Início, Nova Avaliação)
  static const lightOrange = Color(0xFFFFE8D1);
  static const lightRed = Color(0xFFFEE7EA);
  static const lightYellow = Color(0xFFFDF3DF);

  // Semáforo nutricional
  static const statusNormal = green;
  static const statusAttention = Color(0xFFFCB903);
  static const statusRisk = Color(0xFFB8860B);
  static const statusRiskBg = Color(0xFFF6E8B6);
  static const statusBad = red;

  // Tons escuros para TEXTO de status (>= 4.5:1 sobre o fundo claro do selo).
  // As cores acima ficam só para ponto/ícone/fundo.
  static const statusNormalText = Color(0xFF0B7A48); // 4,69:1 sobre lightGreen
  static const statusAttentionText = Color(
    0xFF8A6100,
  ); // 5,03:1 sobre lightYellow
  static const statusRiskText = Color(0xFF8A4B00); // 5,55:1 sobre statusRiskBg
  static const statusBadText = Color(0xFFC62828); // 4,77:1 sobre lightRed
  static const alertCircle = Color(0xFFDA2826); // círculo "!" do resultado
  static const alertText = Color(0xFFA80307); // 6,65:1 sobre lightRed
  static const greenBorder = Color(0xFF066C3E);
}
