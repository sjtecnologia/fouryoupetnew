import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/models/product/product.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/product/components/size_widget.dart';
import 'package:fouryoupet/common/app_network_image.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen(this.product);

  final Product? product;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);

    return ChangeNotifierProvider.value(
      value: product,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 111, 0),
          title: Text(product!.name!, style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 111, 0),
                    Color.fromARGB(255, 255, 161, 0),
                    //Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Consumer<UserManager>(
                builder: (_, userManager, __) {
                  if (userManager.adminEnabled &&
                      !product!.deleted! &&
                      userManager.userapp!.companyID == product!.companyID) {
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                            '/edit_product',
                            arguments: product);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            AspectRatio(
                aspectRatio: 1,
                child: CarouselSlider(
                  options: CarouselOptions(
                      // showIndicator: true,
                      // slideIndicator: CircularSlideIndicator(),
                      ),
                  items: product!.images!.map((url) {
                    return Builder(builder: (BuildContext context) {
                      return AppNetworkImage(imageUrl: url, fit: BoxFit.contain);
                    });
                  }).toList(),
                )
                // Carousel(
                //   images: product!.images!.map((url) {
                //     return NetworkImage(url);
                //   }).toList(),
                //   dotSize: 4,
                //   dotSpacing: 15,
                //   dotBgColor: Colors.transparent,
                //   dotColor: primaryColor,
                //   autoplay: false,
                // ),
                ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'A partir de',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ ${formatter.format(product!.basePrice!)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    product!.description!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (product!.deleted!)
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        'Indisponível',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red),
                      ),
                    )
                  else ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        'Detalhes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product!.sizes!.map((s) {
                        return SizeWidget(size: s);
                      }).toList(),
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  if (product!.hasStock)
                    Consumer2<UserManager, Product>(
                      builder: (_, userManager, product, __) {
                        return SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: product.selectedSize != null
                                ? () {
                                    if (userManager.isLoggedIn) {
                                      context
                                          .read<CartManager>()
                                          .addToCart(product);
                                      Navigator.of(context).pushNamed('/cart');
                                    } else {
                                      Navigator.of(context).pushNamed('/login');
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  Theme.of(context).primaryColor.withAlpha(100),
                            ),
                            child: Text(
                              userManager.isLoggedIn
                                  ? 'Adicionar ao Carrinho'
                                  : 'Entre para Comprar',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
