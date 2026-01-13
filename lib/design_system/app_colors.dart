import 'package:flutter/material.dart';

/// Nova paleta de cores do 4youpet baseada na logo
/// Aprovada em: Dezembro 2024
class AppColors {
  static const AppColors _instance = AppColors._();
  static AppColors get instance => _instance;
  const AppColors._();

  // ===== CORES PRIMÁRIAS (Baseadas na Logo) =====
  /// Laranja vibrante principal
  static const Color primary = Color(0xFFE65100);
  
  /// Laranja claro para hover e estados
  static const Color primaryLight = Color(0xFFFF8A50);
  
  /// Laranja escuro para contraste
  static const Color primaryDark = Color(0xFFBF360C);
  
  /// Laranja suave para elementos secundários
  static const Color primaryAccent = Color(0xFFFFB74D);

  // ===== CORES SECUNDÁRIAS =====
  /// Verde pet - conecta com o mundo animal
  static const Color secondary = Color(0xFF2E7D32);
  
  /// Verde claro
  static const Color secondaryLight = Color(0xFF4CAF50);
  
  /// Verde escuro
  static const Color secondaryDark = Color(0xFF1B5E20);
  
  /// Azul confiança para elementos de confiança
  static const Color accent = Color(0xFF1976D2);

  // ===== CORES NEUTRAS =====
  /// Fundo principal suave
  static const Color background = Color(0xFFFAFAFA);
  
  /// Superfícies (cards, modais)
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Superfícies variantes
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  /// Texto principal
  static const Color onSurface = Color(0xFF212121);
  
  /// Texto secundário
  static const Color onSurfaceVariant = Color(0xFF757575);
  
  /// Bordas e divisores
  static const Color outline = Color(0xFFE0E0E0);
  
  /// Bordas com foco
  static const Color outlineVariant = Color(0xFFBDBDBD);

  // ===== CORES DE STATUS =====
  /// Sucesso
  static const Color success = Color(0xFF4CAF50);
  
  /// Aviso
  static const Color warning = Color(0xFFFF9800);
  
  /// Erro
  static const Color error = Color(0xFFF44336);
  
  /// Informação
  static const Color info = Color(0xFF2196F3);

  // ===== CORES DE AVALIAÇÃO =====
  /// Estrela preenchida
  static const Color starFilled = Color(0xFFFFD700);
  
  /// Estrela vazia
  static const Color starEmpty = Color(0xFFE0E0E0);
  
  /// Estrela hover
  static const Color starHover = Color(0xFFFFB74D);

  // ===== CORES DE FIDELIDADE =====
  /// Bronze
  static const Color bronze = Color(0xFFCD7F32);
  
  /// Prata
  static const Color silver = Color(0xFFC0C0C0);
  
  /// Ouro
  static const Color gold = Color(0xFFFFD700);
  
  /// Platina
  static const Color platinum = Color(0xFFE5E4E2);

  // ===== CORES DE GRADIENTE =====
  /// Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradiente secundário
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== CORES DE SOMBRA =====
  /// Sombra suave
  static const Color shadowLight = Color(0x1A000000);
  
  /// Sombra média
  static const Color shadowMedium = Color(0x33000000);
  
  /// Sombra forte
  static const Color shadowDark = Color(0x4D000000);

  // ===== MÉTODOS AUXILIARES =====
  /// Retorna cor com opacidade
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Retorna cor de texto baseada no fundo
  static Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 
        ? onSurface 
        : surface;
  }
}

/// Extensão para facilitar acesso às cores
extension AppColorsExtension on BuildContext {
  AppColors get colors => AppColors.instance;
}
