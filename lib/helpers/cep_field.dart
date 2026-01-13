import 'package:brasil_fields/brasil_fields.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

class CepField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'CEP',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            TextFormField(
              initialValue: userManager.userapp!.address!
                  .where((a) => a.checked == true)
                  .last
                  .zipCode,
              decoration:
                  const InputDecoration(hintText: '00000-000', isDense: true),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CepInputFormatter(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
