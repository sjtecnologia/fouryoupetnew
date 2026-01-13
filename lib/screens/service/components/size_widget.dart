import 'package:flutter/material.dart';
import 'package:fouryoupet/models/service/item_size.dart';
import 'package:fouryoupet/models/service/service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SizeWidget extends StatelessWidget {
  const SizeWidget({this.size});

  final ItemSize? size;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<Service>();
    final selected = size == service.selectedSize;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);

    Color color;
    if (selected) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        service.selectedSize = size;
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: color)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 230,
              color: color,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                size!.name!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'R\$ ${formatter.format(size!.price)}',
                style: TextStyle(color: color),
              ),
            )
          ],
        ),
      ),
    );
  }
}
