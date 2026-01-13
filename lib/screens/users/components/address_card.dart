import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/users/components/address_input_field.dart';
import 'package:fouryoupet/screens/users/components/cep_input_field.dart';

import 'package:provider/provider.dart';

class AddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(builder: (_, userManager, __) {
      final address =
          userManager.userapp?.address?.where((a) => a.checked == true).last ??
              Address();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: <Widget>[
          const Text(
            'Endereço do Usuário',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          CepInputField(address),
          AddressInputField(address),
        ],
      );
    });
  }
}
