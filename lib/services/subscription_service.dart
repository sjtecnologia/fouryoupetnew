import 'package:cloud_functions/cloud_functions.dart'; // firebase_functions versão > 4.0.0 recomendada

class SubscriptionService {
  final _functions = FirebaseFunctions.instance;

  /// Cria a assinatura recorrente no PagBank
  Future<Map<String, dynamic>> createRecurringSubscription({
    required String userId,
    required String name,
    required String email,
    required String cpf,
    required String cardToken,
    required String planId, // ID criado no PagBank no painel
  }) async {
    final preApprovalId =
        'subscription_${userId}_${DateTime.now().millisecondsSinceEpoch}';

    // Monta o payload do jeito que a função espera
    final params = {
      'customer': {
        'userId': userId,
        'name': name,
        'email': email,
        'cpf': cpf,
      },
      'preApproval': {
        'reference_id': preApprovalId,
        'plan_id': planId,
      },
      'paymentMethod': {
        'cardToken': cardToken,
      }
    };

    try {
      final HttpsCallable callable =
          _functions.httpsCallable('createSubscriptionPagBank');
      final result = await callable(params);
      return {
        'success': true,
        'details': result.data,
      };
    } on FirebaseFunctionsException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
