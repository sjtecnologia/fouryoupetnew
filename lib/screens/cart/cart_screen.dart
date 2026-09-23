import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:fouryoupet/helpers/price_card.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';

import '../../common/empty_card.dart';
import '../../common/login_card.dart';
import '../../models/page_manager.dart';

import 'components/cart_tile.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Carrinho', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<CartManager>(
          builder: (_, cartManager, __) {
            cartManager.deliveryPrice = 0;
            if (cartManager.items.isNotEmpty) {
              cartManager.calculateDeliverynew();
            }

            if (cartManager.user == null) {
              return LoginCard();
            }

            if (cartManager.items.isEmpty) {
              return const EmptyCard(
                iconData: Icons.remove_shopping_cart,
                title: 'Nenhum produto no carrinho',
              );
            } else {
              return ListView(
                padding: EdgeInsets.only(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  bottom: 0,
                ),
                children: <Widget>[
                  ...cartManager.items
                      .map((cartProduct) => CartTile(cartProduct))
                      .toList(),
                  PriceCard(
                    buttonText: 'Continuar',
                    onPressed: cartManager.isCartValid
                        ? () {
                            Navigator.of(context).pushNamed('/address');
                          }
                        : null,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
