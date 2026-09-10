import 'package:flutter/material.dart';
import 'package:fouryoupet/helpers/price_card.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/models/checkout_manager.dart';
import 'package:fouryoupet/models/couponcodes/couponcode_manager.dart';
import 'package:fouryoupet/models/page_manager.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'components/cpf_field.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

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
          title: const Text('Pagamento', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                context.read<PageManager>().setPage(0);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6F00), Color(0xFFFFA100)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Consumer2<CheckoutManager, CouponCodeManager>(
              builder: (_, checkoutManager, couponManager, __) {
                if (checkoutManager.loading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Criando seu checkout seguro...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CpfField(),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                        child: Text(
                          'Você será direcionado ao Mercado Pago. O pedido só é '
                          'confirmado depois da aprovação do pagamento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PriceCard(
                        buttonText: 'Pagar com Mercado Pago',
                        onPressed: () async {
                          if (formKey.currentState?.validate() != true) return;
                          formKey.currentState?.save();
                          await checkoutManager.checkout(
                            onStockFail: (error) {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(message: '$error'),
                              );
                              Navigator.of(context).popUntil(
                                (route) => route.settings.name == '/cart',
                              );
                            },
                            onPayFail: (error) {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(message: '$error'),
                              );
                            },
                            couponManager: couponManager,
                            onSuccess: (order) {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                  message: 'Pagamento aberto. A confirmação é automática.',
                                ),
                              );
                              Navigator.of(context).popUntil(
                                (route) => route.settings.name == '/',
                              );
                              Navigator.of(context).pushNamed(
                                '/confirmation',
                                arguments: order,
                              );
                            },
                          );
                        },
                      ),
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
