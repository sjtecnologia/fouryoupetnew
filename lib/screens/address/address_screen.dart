import 'package:flutter/material.dart';
import 'package:fouryoupet/screens/address/components/address_card_order.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/helpers/price_card.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';

import '../../models/page_manager.dart';

class AddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Entrega', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: true,
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
        child: ListView(
          padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
          ),
          children: <Widget>[
            AddressCardOrder(),
            Consumer<CartManager>(
              builder: (_, cartManager, __) {
                return PriceCard(
                  buttonText: 'Continuar para finalizar',
                  onPressed: cartManager.isAddressValid
                      ? () {
                          Navigator.of(context).pushNamed('/checkout');
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
