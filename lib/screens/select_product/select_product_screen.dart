import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product/product_manager.dart';
import 'package:fouryoupet/common/app_network_image.dart';

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
                leading: AppNetworkImage(imageUrl: product.images!.first, width: 56, height: 56),
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
