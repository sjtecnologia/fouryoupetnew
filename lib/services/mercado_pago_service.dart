import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class MercadoPagoService {
  MercadoPagoService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  final FirebaseFunctions _functions;

  Future<void> connectSeller(String companyId) async {
    final callable = _functions.httpsCallable('beginMercadoPagoConnection');
    final result = await callable.call(<String, dynamic>{'companyId': companyId});
    final data = Map<String, dynamic>.from(result.data as Map);
    final authorizationUrl = Uri.tryParse(data['authorizationUrl'] as String? ?? '');
    if (authorizationUrl == null) {
      throw StateError('Não foi possível iniciar a conexão com o Mercado Pago.');
    }
    final opened = await launchUrl(
      authorizationUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      throw StateError('Não foi possível abrir a autorização do Mercado Pago.');
    }
  }
}

