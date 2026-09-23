import 'package:flutter/material.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/product/product.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/common/app_network_image.dart';

class ProductListTile extends StatelessWidget {
  const ProductListTile(this.product, {this.homeclic});

  final Product product;
  final int? homeclic;

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return GestureDetector(
      onTap: () {
        if (homeclic == null &&
            product.companyID ==
                context.read<UserManager>().userapp?.companyID) {
          Navigator.of(context).pushNamed('/edit_product', arguments: product);
        } else {
          Navigator.of(context).pushNamed('/productcp', arguments: product);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * .5,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Container(
            height: MediaQuery.of(context).size.height * .25,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                if (product.images != null)
                  if (product.images!.length > 0)
                    Container(
                      height: MediaQuery.of(context).size.height * .20,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: AppNetworkImage(
                            imageUrl: product.images!.first,
                          ),
                        ),
                      ),
                    ),
                if (product.images != null)
                  if (product.images!.length == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          'images/no-image-icon-4.png',
                          height: MediaQuery.of(context).size.height * .5,
                          width: MediaQuery.of(context).size.width * .5,
                        ),
                      ),
                    ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                    ),
                    Text(
                      maxLines: 4,
                      product.name?.toUpperCase() ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (context
                            .read<CompanyManager>()
                            .findCompanyByID(product.companyID) !=
                        null)
                      Text(
                        'Vendedor - ' +
                            context
                                .read<CompanyManager>()
                                .findCompanyByID(product.companyID)!
                                .name!,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor),
                      ),
                    if (context
                            .read<CompanyManager>()
                            .findCompanyByID(product.companyID) !=
                        null)
                      Text(
                        context
                                .read<CompanyManager>()
                                .findCompanyByID(product.companyID)!
                                .prazoentrega ??
                            '...',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black45),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'A partir de',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'R\$ ${formatter.format(product.basePrice)}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor),
                    ),
                    if (!product.hasStock)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          'Sem estoque',
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      )
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
