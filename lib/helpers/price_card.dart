// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import '../models/couponcodes/couponcode_manager.dart';
import 'dropdown.dart'; // Certifique-se de que este arquivo existe e é acessível
import 'package:fouryoupet/models/user/user_manager.dart'; // Adicione esta importação para _applyCoupon

class PriceCard extends StatefulWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const PriceCard({
    Key? key,
    required this.buttonText,
    this.onPressed,
  }) : super(key: key);

  @override
  State<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard> {
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponField = false;
  // Adicione esta flag para controlar o estado de "aplicando cupom"
  bool _isApplyingCoupon = false;

  bool _isDeliveryAvailable = false;
  bool _isCheckingDelivery = true;

  // Adicione este método na sua classe
  Future<void> _checkDeliveryAvailability() async {
    final cartManager = Provider.of<CartManager>(context, listen: false);
    final isAvailable = await cartManager.calculateDeliverynew();

    setState(() {
      _isDeliveryAvailable = isAvailable;
      _isCheckingDelivery = false;

      // Se delivery não estiver disponível, força retirada
      if (!isAvailable && (cartManager.delivery ?? false)) {
        cartManager.setDelivery(false);
        cartManager.deliveryPrice = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkDeliveryAvailability();
      await context.read<CartManager>().calculateDeliverynew();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Acessando CartManager e CouponCodeManager via watch para rebuilds
    final cartManager = context.watch<CartManager>();
    final couponManager = context.watch<CouponCodeManager>();

    final productsPrice = cartManager.productsPrice;
    final deliveryPrice =
        cartManager.deliveryPrice ?? 0.0; // Garantindo que não seja nulo

    final discountAmount = couponManager.getDiscountAmount((productsPrice)
        .toDouble()); // O desconto deve ser calculado sobre o total ou subtotal? Ajustei para (subtotal + entrega)
    final totalPrice = productsPrice + deliveryPrice - discountAmount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Resumo do Pedido',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCheckingDelivery)
                  const CircularProgressIndicator()
                else if (_isDeliveryAvailable)
                  // Mostra ambas as opções quando delivery está disponível
                  ToggleButtons(
                    isSelected: [
                      cartManager.delivery ?? false,
                      !(cartManager.delivery ?? false)
                    ],
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: Theme.of(context).primaryColor,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Entrega'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Retirada'),
                      ),
                    ],
                    onPressed: (index) async {
                      if (index == 0 &&
                          (cartManager.delivery != null &&
                              cartManager.delivery!)) {
                        setState(() {
                          _isCheckingDelivery = true;
                        });
                        // Verifica se delivery está disponível
                        final isAvailable =
                            await cartManager.calculateDeliverynew();

                        setState(() {
                          _isCheckingDelivery = false;
                          _isDeliveryAvailable = isAvailable;

                          if (!isAvailable) {
                            // Se não disponível, mantém retirada
                            cartManager.setDelivery(false);
                            cartManager.deliveryPrice = 0;
                          }
                        });
                      } else if (index == 1 &&
                          (cartManager.delivery != null &&
                              cartManager.delivery!)) {
                        setState(() {
                          cartManager.setDelivery(false);
                          cartManager.deliveryPrice = 0;
                        });
                      }
                    },
                  )
                else
                  // Mostra apenas retirada quando delivery não está disponível
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Retirada',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entrega não disponível para seu endereço',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Preço dos produtos (Subtotal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Subtotal'),
                Text('R\$ ${productsPrice.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),

            // Entrega
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Entrega'),
                Text('R\$ ${deliveryPrice.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),

            // Seção de cupom
            _buildCouponSection(
                couponManager,
                (productsPrice)
                    .toDouble()), // Passando o total para o calculo do cupom

            // Desconto (se aplicado)
            if (couponManager.hasCouponApplied) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Desconto (${couponManager.appliedCoupon!.code})',
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text(
                    '- R\$ ${discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],

            const Divider(), // Linha divisória
            const SizedBox(height: 12),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'R\$ ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Visibility(
              visible: widget.buttonText ==
                  'Realizar Pedido', // Mantenha a visibilidade original se houver
              child: DropDown(context.read<CartManager>()),
            ),
            const SizedBox(height: 8),

            // Botão principal
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              onPressed: widget.onPressed,
              child: Text(
                widget.buttonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(
      CouponCodeManager couponManager, double currentTotalForCoupon) {
    return Column(
      children: [
        if (!couponManager.hasCouponApplied && !_showCouponField)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showCouponField = true;
              });
            },
            icon: const Icon(Icons.local_offer),
            label: const Text('Aplicar cupom de desconto'),
          ),
        if (_showCouponField && !couponManager.hasCouponApplied) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Digite o código do cupom',
                    border: const OutlineInputBorder(),
                    errorText: couponManager.errorMessage,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showCouponField = false;
                          _couponController.clear();
                        });
                        couponManager.clearState();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isApplyingCoupon ||
                        couponManager.isLoading // Use _isApplyingCoupon
                    ? null
                    : () => _applyCoupon(couponManager, currentTotalForCoupon),
                child: _isApplyingCoupon || couponManager.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Aplicar'),
              ),
            ],
          ),
        ],
        if (couponManager.hasCouponApplied) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cupom ${couponManager.appliedCoupon!.code} aplicado!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    couponManager.removeCoupon();
                    setState(() {
                      _showCouponField = false;
                      _couponController.clear();
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.green.shade600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _applyCoupon(
      CouponCodeManager couponManager, double currentTotalForCoupon) async {
    if (_couponController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um código de cupom')),
      );
      return;
    }

    // Obtenha o userId do UserManager
    final userManager = context.read<UserManager>();
    final userId = userManager.userapp?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para usar um cupom.')),
      );
      return;
    }

    setState(() {
      _isApplyingCoupon = true; // Define a flag antes de chamar a API
    });

    final success = await couponManager.applyCoupon(
      _couponController.text.trim(),
      currentTotalForCoupon,
      userId,
    );

    setState(() {
      _isApplyingCoupon = false; // Reseta a flag após a chamada da API
    });

    if (success) {
      setState(() {
        _showCouponField = false;
      });
      _couponController.clear();
    }
  }
}
