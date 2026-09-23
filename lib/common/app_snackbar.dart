import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

/// Helper centralizado para exibir snackbars no app.
///
/// Uso:
///   AppSnackBar.success(context, 'Operação realizada!');
///   AppSnackBar.error(context, 'Algo deu errado.');
///   AppSnackBar.info(context, 'Atenção!');
class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(message: message),
    );
  }

  static void error(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(message: message),
    );
  }

  static void info(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(message: message),
    );
  }
}
