import 'package:flutter/material.dart';
import 'package:fouryoupet/models/cart/cart_product.dart';
import 'package:intl/intl.dart';

import '../../models/order/order.dart';
import 'package:fouryoupet/common/app_network_image.dart';

class OrderProductTile extends StatelessWidget {
  const OrderProductTile(this.cartProduct, this.order);

  final CartProduct cartProduct;
  final Order order;

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed('/product', arguments: cartProduct.product);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 60,
              width: 60,
              child: AppNetworkImage(imageUrl: cartProduct.product!.images!.first),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    cartProduct.product!.name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Detalhes: ${cartProduct.sizes}',
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'R\$ ${(formatter.format(cartProduct.totalPrice))}',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text(
              '${cartProduct.quantity}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
