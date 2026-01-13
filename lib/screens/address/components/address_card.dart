import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import 'package:provider/provider.dart';

import 'address_input_field.dart';
import 'cep_input_field.dart';

class AddressCard extends StatelessWidget {
  final bool adding;
  final Address address;

  const AddressCard({Key? key, required this.adding, required this.address})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Consumer<UserManager>(builder: (_, userManager, __) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Endereço de Entrega',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (userManager.editing && this.address.zipCode == null)
                    CepInputField(this.address),
                  if (userManager.userapp?.address != null)
                    if (!userManager.editing)
                      AddressInputField(userManager.userapp!.address!.last),
                  if (this.address.zipCode != null)
                    AddressInputField(this.address),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
