import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/couponcodes/couponcode_manager.dart';
import '../../../models/user/user_manager.dart';

class CouponField extends StatefulWidget {
  final double cartTotal; // Adicione este parâmetro

  const CouponField({
    Key? key,
    required this.cartTotal,
  }) : super(key: key);

  @override
  _CouponFieldState createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  final TextEditingController _couponController =
      TextEditingController(); // Nome correto
  bool _showCouponField = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponCodeManager>(
      builder: (context, couponManager, _) {
        return Column(
          children: [
            // Botão para mostrar/esconder campo do cupom
            if (!_showCouponField && !couponManager.hasCouponApplied)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showCouponField = true;
                  });
                },
                child: Text('Tenho um cupom de desconto'),
              ),

            // Campo do cupom
            if (_showCouponField && !couponManager.hasCouponApplied)
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            decoration: InputDecoration(
                              labelText: 'Código do cupom',
                              border: OutlineInputBorder(),
                              errorText: couponManager.errorMessage,
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed:
                              couponManager.isLoading ? null : _applyCoupon,
                          child: couponManager.isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text('Aplicar'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showCouponField = false;
                        });
                        _couponController.clear();
                        couponManager.clearState();
                      },
                      child: Text('Cancelar'),
                    ),
                  ],
                ),
              ),

            // Cupom aplicado
            if (couponManager.hasCouponApplied)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cupom aplicado!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Desconto: R\$ ${couponManager.getDiscountAmount(widget.cartTotal).toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        couponManager.clearState();
                        setState(() {
                          _showCouponField = false;
                        });
                      },
                      icon: Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.trim().isEmpty) {
      return;
    }

    final couponManager = context.read<CouponCodeManager>();
    final userManager = context.read<UserManager>();

    // Pega o userId do usuário logado
    final userId = userManager.userapp?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário não está logado')),
      );
      return;
    }

    final success = await couponManager.applyCoupon(
      _couponController.text.trim(),
      widget.cartTotal, // Valor do carrinho (double)
      userId, // ID do usuário
    );

    if (success) {
      setState(() {
        _showCouponField = false;
      });
      _couponController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cupom aplicado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
