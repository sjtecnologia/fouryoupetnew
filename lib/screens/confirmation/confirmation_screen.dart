import 'package:flutter/material.dart';
import 'package:fouryoupet/models/order/order.dart';
import 'package:fouryoupet/common/order/order_product_tile.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/page_manager.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen(this.order);

  final Order? order;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pedido ${widget.order!.formattedId} Confirmado',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              // Se necessário, feche telas abertas
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Nro. do Pedido: ${widget.order!.formattedId}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          'Total do Pedido: R\$ ${formatter.format(widget.order!.price!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Valor do Frete: R\$ ${formatter.format(widget.order!.frete!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        if (widget.order?.discount != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Desconto aplicado: R\$ ${widget.order?.discount!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          if (widget.order?.couponCode != null)
                            Text(
                              'Cupom: ${widget.order?.couponCode}',
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          Text(
                            'Total com Desconto: R\$ ${formatter.format(widget.order!.price! - widget.order!.discount!)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        LinearProgressIndicator(
                          value: controller.value,
                          semanticsLabel: widget.order?.statusText,
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: widget.order!.items!.map((e) {
                      return OrderProductTile(e, widget.order!);
                    }).toList(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
