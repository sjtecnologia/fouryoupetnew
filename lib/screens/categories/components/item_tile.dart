import 'package:flutter/material.dart';
import 'package:fouryoupet/models/accommodation/accommodation_params.dart';
import 'package:fouryoupet/models/categories/categories_section_item.dart';
import 'package:fouryoupet/models/company/company.dart';
import 'package:fouryoupet/models/product/product_manager.dart';

import 'package:fouryoupet/screens/accommodations/accommodations_screen.dart';
import 'package:fouryoupet/screens/products/products_screencp.dart';

import 'package:fouryoupet/screens/services/services_screencp.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
//import 'package:universal_io/io.dart';
import 'dart:io';

class ItemTile extends StatelessWidget {
  ItemTile(this.item, this.company, {this.homeclic});

  final CategoriesSectionItem item;
  final Company? company;
  final int? homeclic;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white, //Theme.of(context).primaryColor,
      shadowColor: Theme.of(context).primaryColor,
      //color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            final accParamsct =
                AccommodationParams.fromtotal(company!, item, homeclic!);

            if (homeclic == 1) {
              context.read<ProductManager>().prodsSnapshot.clear();
              context.read<ProductManager>().products.clear();
              context.read<ProductManager>().hasNext = true;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductsScreencp(
                            categoring: true,
                            homeclic: homeclic,
                            companyid: company!.id,
                            categoria: item.pos,
                            productManager: context.read<ProductManager>(),
                          )));
            } else if (homeclic != 4)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ServicesScreencp(
                            categoring: true,
                            homeclic: homeclic,
                            companyid: company!.id,
                            categoria: item.pos,
                          )));
            else
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccommodationsScreen(
                            accommodationParams: accParamsct,
                            categoring: true,
                            homeclic: homeclic,
                          )));
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: item.image is String
                ? FadeInImage.memoryNetwork(
                    alignment: Alignment.center,
                    placeholder: kTransparentImage,

                    image: item.image as String,
                    //fit: BoxFit.cover,
                  )
                : Image.file(
                    item.image as File,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }
}
