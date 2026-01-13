import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/screens/address/components/address_input_field_order.dart';
import 'package:provider/provider.dart';

import 'cep_input_field_order.dart';

class AddressCardOrder extends StatefulWidget {
  @override
  State<AddressCardOrder> createState() => _AddressCardOrderState();
}

class _AddressCardOrderState extends State<AddressCardOrder> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(builder: (_, cartManager, __) {
      final address = cartManager.user?.address
          ?.where((a) => a.checked == true)
          .toList()
          .first as Address;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Endereço de Entrega',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        CepInputFieldOrder(address),
                        AddressInputFieldOrder(address),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed('/listadress', arguments: 'c');
                    },
                    icon:
                        Icon(Icons.published_with_changes, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
