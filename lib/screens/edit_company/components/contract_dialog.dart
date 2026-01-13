import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; // Importar aqui

/// Exibe um modal com o contrato para leitura e um checkbox de aceite.
/// Retorna true se o usuário marcar "Li e aceito" e confirmar.
Future<bool?> showContractDialog(
  BuildContext context, {
  required String contractHtmlContent, // Conteúdo HTML do contrato
  required String contractVersion,     // Versão do contrato
  String title = 'Contrato de Adesão',
  String acceptLabel = 'Li e aceito os termos do contrato',
  String confirmButtonText = 'Aceitar e continuar',
  String cancelButtonText = 'Cancelar',
  bool barrierDismissible = false,
}) async {
  bool accepted = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible, // força o fechamento apenas pelos botões
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(ctx);
          final size = MediaQuery.of(ctx).size;
          final maxHeight = size.height * 0.75; // até 75% da altura da tela

          return AlertDialog(
            title: Text('$title (v$contractVersion)', style: theme.textTheme.titleLarge),
            content: SizedBox(
              width: double.maxFinite,
              height: maxHeight,
              child: Column(
                children: [
                  // Conteúdo rolável do contrato (agora usando HtmlWidget)
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 8),
                        child: HtmlWidget(
                          contractHtmlContent,
                          // Configurações opcionais para o HtmlWidget
                          // Ex: onTapUrl: (url) => launchUrl(Uri.parse(url!)),
                          // webView: true, // Para renderizar HTML mais complexo (requer webview_flutter)
                          textStyle: theme.textTheme.bodyMedium,
                          buildAsync: true, // Renderiza em segundo plano
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Checkbox de aceite
                  CheckboxListTile(
                    value: accepted,
                    onChanged: (v) => setState(() => accepted = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    title: Text(
                      acceptLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(cancelButtonText),
              ),
              FilledButton(
                onPressed: accepted ? () => Navigator.of(ctx).pop(true) : null,
                child: Text(confirmButtonText),
              ),
            ],
          );
        },
      );
    },
  );
}