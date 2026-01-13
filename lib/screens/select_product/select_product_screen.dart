import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product/product_manager.dart';

class SelectProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Vincular Produto'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Consumer<ProductManager>(
        builder: (_, productManager, __) {
          return ListView.builder(
            itemCount: productManager.products.length,
            itemBuilder: (_, index) {
              final product = productManager.products[index];
              return ListTile(
                leading: Image.network(product.images!.first),
                title: Text(product.name!),
                subtitle: Text('R\$ ${formatter.format(product.basePrice)}'),
                onTap: () {
                  Navigator.of(context).pop(product);
                },
              );
            },
          );
        },
      ),
    );
  }
}
