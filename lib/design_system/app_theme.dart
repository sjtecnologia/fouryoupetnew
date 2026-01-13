import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Tema principal do 4youpet
/// Baseado na nova paleta de cores aprovada
class AppTheme {
  static const AppTheme _instance = AppTheme._();
  static AppTheme get instance => _instance;
  const AppTheme._();

  // ===== TEMA CLARO =====
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // ===== CORES =====
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        
        tertiary: AppColors.accent,
        onTertiary: Colors.white,
        
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        
        background: AppColors.background,
        onBackground: AppColors.onSurface,
        
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        
        shadow: AppColors.shadowLight,
        scrim: AppColors.shadowMedium,
      ),
      
      // ===== TIPOGRAFIA =====
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        headlineLarge: AppTypography.h4,
        headlineMedium: AppTypography.h5,
        headlineSmall: AppTypography.h6,
        titleLarge: AppTypography.h4,
        titleMedium: AppTypography.h5,
        titleSmall: AppTypography.h6,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      
      // ===== APP BAR =====
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h5,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // ===== BOTÕES =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // ===== CARDS =====
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // ===== INPUTS =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      
      // ===== BOTTOM NAVIGATION =====
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // ===== FLOATING ACTION BUTTON =====
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // ===== DIVIDER =====
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      
      // ===== CHIP =====
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.outline,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // ===== PROGRESS INDICATOR =====
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.outline,
        circularTrackColor: AppColors.outline,
      ),
      
      // ===== SNACKBAR =====
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== TEMA ESCURO (FUTURO) =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.primaryDark,
        primaryContainer: AppColors.primary,
        onPrimaryContainer: Colors.white,
        
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.secondaryDark,
        secondaryContainer: AppColors.secondary,
        onSecondaryContainer: Colors.white,
        
        tertiary: AppColors.accent,
        onTertiary: Colors.white,
        
        error: AppColors.error,
        onError: Colors.white,
        
        surface: Color(0xFF121212),
        onSurface: Colors.white,
        surfaceVariant: Color(0xFF2C2C2C),
        onSurfaceVariant: Color(0xFFB3B3B3),
        
        background: Color(0xFF0F0F0F),
        onBackground: Colors.white,
        
        outline: Color(0xFF404040),
        outlineVariant: Color(0xFF2C2C2C),
      ),
      
      // Reutiliza a tipografia do tema claro
      textTheme: lightTheme.textTheme,
      
      // Reutiliza outros temas com ajustes mínimos
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF121212),
      ),
      
      cardTheme: lightTheme.cardTheme.copyWith(
        color: const Color(0xFF2C2C2C),
      ),
    );
  }
}

/// Extensão para facilitar acesso ao tema
extension AppThemeExtension on BuildContext {
  AppTheme get appTheme => AppTheme.instance;
}
