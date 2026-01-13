// lib/services/pagbank_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class PagBankService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Obter chave pública do PagBank
  Future<String> getPublicKey() async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('getPagBankPublicKey');
      final result = await callable.call();
      return result.data['publicKey'];
    } catch (e) {
      throw Exception('Erro ao obter chave pública: $e');
    }
  }

  // Criar assinatura
  Future<Map<String, dynamic>> createSubscription({
    required String companyId,
    required String encryptedCard,
    required String cardHolder,
    required String cpf,
    required String phone,
    required Map<String, String> address,
    required String security_code,
  }) async {
    try {
      debugPrint(
          'Criando assinatura com os seguintes dados: $encryptedCard, $cardHolder, $cpf, $phone, $address, $companyId, $security_code');
      final HttpsCallable callable =
          _functions.httpsCallable('createPagBankSubscription');
      final result = await callable.call({
        'companyId': companyId,
        'encryptedCard': encryptedCard,
        'cardHolder': cardHolder,
        'cpf': cpf,
        'phone': phone,
        'address': address,
        'security_code': security_code,
      });

      return result.data;
    } catch (e) {
      debugPrint('Erro ao criar assinatura: $e');
      throw Exception('Erro ao criar assinatura: $e');
    }
  }

  Future<Map<String, dynamic>> cancelSubscription({
    required String subscriptionId,
    required String companyID,
  }) async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('cancelPagBankSubscription');
      final result = await callable.call({
        'subscriptionId': subscriptionId,
        'companyID': companyID,
      });

      return result.data;
    } catch (e) {
      debugPrint('Erro ao cancelar assinatura: $e');
      throw Exception('Erro ao cancelar assinatura: $e');
    }
  }

  // Criptografar cartão usando WebView
  Future<String> encryptCard({
    required String publicKey,
    required String cardNumber,
    required String cardHolder,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required BuildContext context,
  }) async {
    final completer = Completer<String>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: SizedBox(
              height: 1,
              width: 1,
              child: _PagBankWebView(
                publicKey: publicKey,
                cardNumber: cardNumber,
                cardHolder: cardHolder,
                expiryMonth: expiryMonth,
                expiryYear: expiryYear,
                cvv: cvv,
                onEncrypted: (encryptedCard) {
                  Navigator.of(context).pop();
                  completer.complete(encryptedCard);
                },
                onError: (error) {
                  Navigator.of(context).pop();
                  completer.completeError(error);
                },
              ),
            ),
          ),
        );
      },
    );

    return completer.future;
  }
}

// Widget WebView para criptografia
class _PagBankWebView extends StatefulWidget {
  final String publicKey;
  final String cardNumber;
  final String cardHolder;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final Function(String) onEncrypted;
  final Function(String) onError;

  const _PagBankWebView({
    required this.publicKey,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.onEncrypted,
    required this.onError,
  });

  @override
  State<_PagBankWebView> createState() => _PagBankWebViewState();
}

class _PagBankWebViewState extends State<_PagBankWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message.startsWith('ERROR:')) {
            widget.onError(message.message.substring(6));
          } else {
            widget.onEncrypted(message.message);
          }
        },
      )
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <script src="https://assets.pagseguro.com.br/checkout-sdk-js/rc/dist/browser/pagseguro.min.js"></script>
        </head>
        <body>
          <script>
            try {
              const card = PagSeguro.encryptCard({
                publicKey: "${widget.publicKey}",
                holder: "${widget.cardHolder}",
                number: "${widget.cardNumber}",
                expMonth: "${widget.expiryMonth}",
                expYear: "${widget.expiryYear}",
                securityCode: "${widget.cvv}"
              });
              
              if (card.hasErrors) {
                Flutter.postMessage('ERROR: ' + JSON.stringify(card.errors));
              } else {
                Flutter.postMessage(card.encryptedCard);
              }
            } catch (error) {
              Flutter.postMessage('ERROR: ' + error.message);
            }
          </script>
        </body>
        </html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
