import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// Botões padronizados do 4youpet
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final textStyle = _getTextStyle();
    final padding = _getPadding();

    Widget textWidget = Text(
      text,
      style: textStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.center,
    );

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: textWidget),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
          Flexible(child: textWidget),
        ] else
          textWidget,
      ],
    );

    if (type == AppButtonType.primary) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: Padding(
            padding: padding,
            child: buttonChild,
          ),
        ),
      );
    } else if (type == AppButtonType.secondary) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: Padding(
            padding: padding,
            child: buttonChild,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: Padding(
            padding: padding,
            child: buttonChild,
          ),
        ),
      );
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case AppButtonType.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
        return AppTypography.buttonMedium;
      case AppButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 20;
    }
  }
}

/// Tipos de botão
enum AppButtonType {
  primary,
  secondary,
  text,
}

/// Tamanhos de botão
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Botão de ação flutuante customizado
class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final AppButtonSize size;

  const AppFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.size = AppButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        size: _getIconSize(),
      ),
    );
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 20;
      case AppButtonSize.medium:
        return 24;
      case AppButtonSize.large:
        return 28;
    }
  }
}
