// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:fouryoupet/models/address/address.dart';

import 'package:fouryoupet/screens/edit_company/components/address_input_field.dart';
import 'package:fouryoupet/screens/edit_company/components/cep_input_field.dart';
import 'package:provider/provider.dart';

import '../../../models/company/company.dart';
import '../../../models/company/company_manager.dart';

class AddressCard extends StatefulWidget {
  final Company company;
  const AddressCard({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    final companyManager = context.watch<CompanyManager>();
    if (companyManager.company == null) companyManager.company = widget.company;
    final address = companyManager.company?.address ?? Address();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Endereço',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        CepInputField(address),
        AddressInputField(address),
      ],
    );
  }
}
