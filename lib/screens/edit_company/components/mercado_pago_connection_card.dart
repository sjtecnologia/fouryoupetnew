import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/services/mercado_pago_service.dart';

class MercadoPagoConnectionCard extends StatefulWidget {
  const MercadoPagoConnectionCard({
    required this.companyId,
    super.key,
  });

  final String companyId;

  @override
  State<MercadoPagoConnectionCard> createState() =>
      _MercadoPagoConnectionCardState();
}

class _MercadoPagoConnectionCardState
    extends State<MercadoPagoConnectionCard> {
  final MercadoPagoService _service = MercadoPagoService();
  bool _loading = false;

  Future<void> _connect() async {
    setState(() => _loading = true);
    try {
      await _service.connectSeller(widget.companyId);
    } on FirebaseFunctionsException catch (error) {
      _showError(error.message ?? 'Falha ao conectar o Mercado Pago.');
    } catch (error) {
      _showError(
        error is StateError
            ? error.message.toString()
            : 'Falha ao conectar o Mercado Pago.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('companys')
          .doc(widget.companyId)
          .snapshots(),
      builder: (context, snapshot) {
        final integration = snapshot.data?.data()?['mercadoPago'];
        final connected = integration is Map && integration['connected'] == true;

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      connected ? Icons.verified : Icons.account_balance_wallet,
                      color: connected ? Colors.green : const Color(0xFF009EE3),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Recebimentos Mercado Pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  connected
                      ? 'Conta conectada. As vendas aprovadas são repassadas '
                          'automaticamente, já com a comissão contratual.'
                      : 'Conecte a conta do petshop para receber vendas do app. '
                          'A 4YouPet não vê nem armazena sua senha.',
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _connect,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(connected ? Icons.sync : Icons.open_in_new),
                  label: Text(
                    connected
                        ? 'Reconectar conta Mercado Pago'
                        : 'Conectar Mercado Pago',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009EE3),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
