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
import '../../services/pagbank_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _cardNumber = TextEditingController();
  final _holder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  String _paymentMethod = 'PIX';

  @override
  void dispose() {
    _cardNumber.dispose();
    _holder.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

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
                            child: Column(
                              children: [
                                CpfField(),
                                DropdownButtonFormField<String>(
                                  value: _paymentMethod,
                                  decoration: const InputDecoration(
                                      labelText: 'Forma de pagamento'),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'PIX', child: Text('PIX')),
                                    DropdownMenuItem(
                                        value: 'CREDIT_CARD',
                                        child: Text('Cartão de crédito')),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _paymentMethod = value!),
                                ),
                                if (_paymentMethod == 'CREDIT_CARD') ...[
                                  TextFormField(
                                      controller: _holder,
                                      decoration: const InputDecoration(
                                          labelText: 'Nome no cartão'),
                                      validator: (v) => v!.isEmpty
                                          ? 'Informe o titular'
                                          : null),
                                  TextFormField(
                                      controller: _cardNumber,
                                      decoration: const InputDecoration(
                                          labelText: 'Número do cartão'),
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v!.isEmpty
                                          ? 'Informe o cartão'
                                          : null),
                                  TextFormField(
                                      controller: _expiry,
                                      decoration: const InputDecoration(
                                          labelText: 'Validade MM/AAAA'),
                                      validator: (v) => v!.isEmpty
                                          ? 'Informe a validade'
                                          : null),
                                  TextFormField(
                                      controller: _cvv,
                                      decoration: const InputDecoration(
                                          labelText: 'CVV'),
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Informe o CVV' : null),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      PriceCard(
                        buttonText: 'Realizar Pedido',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            String? encryptedCard;
                            if (_paymentMethod == 'CREDIT_CARD') {
                              final parts = _expiry.text.split('/');
                              encryptedCard =
                                  await PagBankService().encryptCard(
                                publicKey:
                                    await PagBankService().getPublicKey(),
                                cardNumber:
                                    _cardNumber.text.replaceAll(' ', ''),
                                cardHolder: _holder.text,
                                expiryMonth: parts.first,
                                expiryYear: parts.length > 1 ? parts.last : '',
                                cvv: _cvv.text,
                                context: context,
                              );
                            }
                            checkoutManager.checkout(
                                paymentMethod: _paymentMethod,
                                encryptedCard: encryptedCard,
                                securityCode: _cvv.text,
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
                                onSuccess: (order, payment) {
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
                                      message: payment.status == 'PAID'
                                          ? "Pedido realizado! Você ganhou $points pontos! 🎉"
                                          : "PIX criado. Escaneie o QR Code para pagar.",
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
