import 'package:flutter/material.dart';
import '../../design_system/app_colors.dart';

class ColorsApp {
  static ColorsApp? _instance;

  ColorsApp._();
  static ColorsApp get instance {
    _instance ??= ColorsApp._();
    return _instance!;
  }

  // Mantém compatibilidade com código existente
  Color get primary => AppColors.primary;
  Color get secondary => AppColors.secondary;
  Color get black => AppColors.onSurface;
  
  // Adiciona novas cores do design system
  Color get primaryLight => AppColors.primaryLight;
  Color get primaryDark => AppColors.primaryDark;
  Color get accent => AppColors.accent;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get error => AppColors.error;
  Color get background => AppColors.background;
  Color get surface => AppColors.surface;
  Color get onSurface => AppColors.onSurface;
  Color get onSurfaceVariant => AppColors.onSurfaceVariant;
}

extension ColorsAppExtensions on BuildContext {
  ColorsApp get colors => ColorsApp.instance;
}
