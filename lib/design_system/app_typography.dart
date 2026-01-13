import 'package:flutter/material.dart';

/// Sistema de tipografia do 4youpet
/// Baseado em Inter para melhor legibilidade
class AppTypography {
  static const AppTypography _instance = AppTypography._();
  static AppTypography get instance => _instance;
  const AppTypography._();

  // ===== FONT FAMILY =====
  static const String fontFamily = 'Inter';
  static const String fontFamilyFallback = 'Roboto';

  // ===== HEADINGS =====
  /// H1 - Títulos principais
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// H2 - Títulos secundários
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.3,
    fontFamily: fontFamily,
  );

  /// H3 - Títulos de seção
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// H4 - Títulos de card
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// H5 - Subtítulos
  static const TextStyle h5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
    fontFamily: fontFamily,
  );

  /// H6 - Títulos pequenos
  static const TextStyle h6 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    fontFamily: fontFamily,
  );

  // ===== BODY TEXT =====
  /// Body Large - Texto principal
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
    fontFamily: fontFamily,
  );

  /// Body Medium - Texto padrão
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// Body Small - Texto secundário
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.3,
    fontFamily: fontFamily,
  );

  // ===== LABELS =====
  /// Label Large - Labels grandes
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    fontFamily: fontFamily,
  );

  /// Label Medium - Labels médios
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
    fontFamily: fontFamily,
  );

  /// Label Small - Labels pequenos
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
    fontFamily: fontFamily,
  );

  // ===== BUTTONS =====
  /// Button Large - Botões grandes
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// Button Medium - Botões médios
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// Button Small - Botões pequenos
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
    fontFamily: fontFamily,
  );

  // ===== CAPTION =====
  /// Caption - Texto de legenda
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// Overline - Texto de sobreposição
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.2,
    fontFamily: fontFamily,
  );

  // ===== ESPECIAIS =====
  /// Price - Preços
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// Price Small - Preços pequenos
  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// Rating - Avaliações
  static const TextStyle rating = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.2,
    fontFamily: fontFamily,
  );

  /// Error - Textos de erro
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.2,
    fontFamily: fontFamily,
  );

  // ===== MÉTODOS AUXILIARES =====
  /// Aplica cor ao texto
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Aplica peso da fonte
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Aplica tamanho da fonte
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

/// Extensão para facilitar acesso à tipografia
extension AppTypographyExtension on BuildContext {
  AppTypography get typography => AppTypography.instance;
}
