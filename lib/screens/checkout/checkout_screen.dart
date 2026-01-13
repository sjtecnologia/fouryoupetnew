import 'package:flutter/material.dart';
import 'package:fouryoupet/models/couponcodes/couponcode_manager.dart';
import 'package:fouryoupet/models/loyalty/loyalty_manager.dart';
import 'package:fouryoupet/models/loyalty/loyalty.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/helpers/price_card.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/models/checkout_manager.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/page_manager.dart';

import 'components/cpf_field.dart';

class CheckoutScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<CartManager, CheckoutManager?>(
      create: (_) => CheckoutManager(),
      update: (_, cartManager, checkoutManager) =>
          checkoutManager!..updateCart(cartManager),
      lazy: false,
      child: Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Pedido', style: TextStyle(color: Colors.white)),
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
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child:
                Consumer3<CheckoutManager, CouponCodeManager, LoyaltyManager>(
              builder: (_, checkoutManager, couponManager, loyaltyManager, __) {
                if (checkoutManager.loading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <Widget>[
                        const CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          'Processando seu pedido...',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return Form(
                  key: formKey,
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: kToolbarHeight + MediaQuery.of(context).padding.top,
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CpfField(),
                          ),
                        ),
                      ),
                      PriceCard(
                        buttonText: 'Realizar Pedido',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            checkoutManager.checkout(
                                onStockFail: (e) {
                                  Navigator.of(context).popUntil((route) =>
                                      route.settings.name == '/cart');
                                },
                                onPayFail: (e) {
                                  // ignore: deprecated_member_use
                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.error(
                                      message: "Erro: $e",
                                    ),
                                  );
                                },
                                couponManager: couponManager,
                                loyaltyManager: loyaltyManager,
                                onSuccess: (order) {
                                  // Calcular pontos ganhos
                                  final orderValue =
                                      order.price?.toDouble() ?? 0.0;
                                  final tier = loyaltyManager
                                          .loyaltyProgram?.currentTier ??
                                      LoyaltyTier.bronze;
                                  final points = loyaltyManager
                                      .calculatePointsFromPurchase(
                                    orderValue,
                                    tier,
                                  );

                                  showTopSnackBar(
                                    Overlay.of(context),
                                    CustomSnackBar.success(
                                      message:
                                          "Pedido realizado! Você ganhou $points pontos! 🎉",
                                    ),
                                  );

                                  Navigator.of(context).popUntil(
                                      (route) => route.settings.name == '/');
                                  Navigator.of(context).pushNamed(
                                      '/confirmation',
                                      arguments: order);
                                });
                          }
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
