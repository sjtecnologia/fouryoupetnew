import 'package:flutter/material.dart';
import 'package:fouryoupet/common/dropdown.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';

class PriceCard extends StatefulWidget {
  const PriceCard({this.buttonText, this.onPressed});

  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  State<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard> {
  bool _isDeliveryAvailable = false;
  bool _isCheckingDelivery = true;

  // Adicione este método na sua classe
  Future<void> _checkDeliveryAvailability() async {
    final cartManager = Provider.of<CartManager>(context, listen: false);
    final isAvailable = await cartManager.calculateDeliverynew();

    setState(() {
      _isDeliveryAvailable = isAvailable;
      _isCheckingDelivery = false;

      // Se delivery não estiver disponível, força retirada
      if (!isAvailable && (cartManager.delivery ?? false)) {
        cartManager.setDelivery(false);
        cartManager.deliveryPrice = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeliveryAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = context.watch<CartManager>();
    final productsPrice = cartManager.productsPrice;
    final deliveryPrice = cartManager.deliveryPrice;
    final totalPrice = cartManager.totalPrice;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Resumo do Pedido',
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCheckingDelivery)
                  const CircularProgressIndicator()
                else if (_isDeliveryAvailable)
                  // Mostra ambas as opções quando delivery está disponível
                  ToggleButtons(
                    isSelected: [
                      cartManager.delivery ?? false,
                      !(cartManager.delivery ?? false)
                    ],
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: Theme.of(context).primaryColor,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Entrega'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Retirada'),
                      ),
                    ],
                    onPressed: (index) {
                      if (index == 0 &&
                          (cartManager.delivery != null &&
                              !cartManager.delivery!)) {
                        cartManager.calculateDeliverynew();
                        cartManager.setDelivery(true);
                      } else if (index == 1 &&
                          (cartManager.delivery != null &&
                              cartManager.delivery!)) {
                        cartManager.setDelivery(false);
                        cartManager.deliveryPrice = 0;
                      }
                    },
                  )
                else
                  // Mostra apenas retirada quando delivery não está disponível
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Retirada',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entrega não disponível para seu endereço',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Subtotal'),
                Text('R\$ ${formatter.format(productsPrice)}')
              ],
            ),
            const Divider(),
            if (deliveryPrice != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Entrega'),
                  Text('R\$ ${formatter.format(deliveryPrice)}')
                ],
              ),
              const Divider(),
            ],

            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'R\$ ${formatter.format(totalPrice)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            DropDown(cartManager),
            // ignore: deprecated_member_use
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Theme.of(context).primaryColor.withAlpha(100),
              ),
              onPressed: widget.onPressed,
              child: Text(widget.buttonText!),
            ),
          ],
        ),
      ),
    );
  }
}
