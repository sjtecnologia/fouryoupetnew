import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fouryoupet/models/home_manager.dart';
import 'package:fouryoupet/models/product/product.dart';

import 'package:fouryoupet/models/section/section.dart';
import 'package:fouryoupet/models/section/section_item.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../models/product/product_manager.dart';

class ItemTile extends StatelessWidget {
  const ItemTile(this.item);

  final SectionItem item;

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<HomeManager>();
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return GestureDetector(
      onTap: () {
        if (item.product != null) {
          final product =
              context.read<ProductManager>().findProductByID(item.product);
          if (product != null) {
            Navigator.of(context).pushNamed('/product', arguments: product);
          }
        }
      },
      onLongPress: homeManager.editing
          ? () {
              showDialog(
                  context: context,
                  builder: (_) {
                    final product = context
                        .read<ProductManager>()
                        .findProductByID(item.product);
                    return AlertDialog(
                      title: const Text('Editar Item'),
                      content: product != null
                          ? ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Image.network(product.images!.first),
                              title: Text(product.name!),
                              subtitle: Text(
                                  'R\$ ${formatter.format(product.basePrice)}'),
                            )
                          : null,
                      actions: <Widget>[
                        // ignore: deprecated_member_use
                        TextButton(
                          onPressed: () {
                            context.read<Section>().removeItem(item);
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: const Text('Excluir'),
                        ),
                        // ignore: deprecated_member_use
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            if (product != null) {
                              item.product = null;
                            } else {
                              final Product? product =
                                  await Navigator.of(context)
                                      .pushNamed('/select_product') as Product?;
                              item.product = product?.id;
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text(
                              product != null ? 'Desvincular' : 'Vincular'),
                        ),
                      ],
                    );
                  });
            }
          : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: item.image is String
            ? FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: item.image as String,
                fit: BoxFit.cover,
              )
            : Image.file(
                item.image as File,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
