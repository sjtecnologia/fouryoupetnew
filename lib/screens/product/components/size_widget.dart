import 'package:flutter/material.dart';
import 'package:fouryoupet/models/product/item_size.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/product/product.dart';

class SizeWidget extends StatelessWidget {
  const SizeWidget({this.size});

  final ItemSize? size;

  @override
  Widget build(BuildContext context) {
    final product = context.watch<Product>();
    final selected = size == product.selectedSize;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    Color color;
    if (!size!.hasStock) {
      color = Colors.red.withAlpha(50);
    } else if (selected) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (size!.hasStock) {
          product.selectedSize = size;
        }
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: color)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              color: color,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                size!.name!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'R\$ ${formatter.format(size!.price!)}',
                  style: TextStyle(color: color),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
