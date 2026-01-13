import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/company/company_manager.dart';

import 'package:provider/provider.dart';

class AddressInputField extends StatelessWidget {
  const AddressInputField(this.address);

  final Address address;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final companyManager = context.watch<CompanyManager>();
    // final address = companyManager.company?.address;

    String? emptyValidator(String? text) =>
        text!.isEmpty ? 'Campo obrigatório' : null;

    if (address.zipCode != null && address.number == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            enabled: !companyManager.loading,
            initialValue: address.street,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Rua/Avenida',
              hintText: 'Av.Brasil',
            ),
            validator: emptyValidator,
            onSaved: (t) => address.street = t,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  enabled: !companyManager.loading,
                  initialValue: address.number,
                  decoration: const InputDecoration(
                      isDense: true, labelText: 'Número', hintText: '123'),
                  inputFormatters: [
                    // ignore: deprecated_member_use
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  keyboardType: TextInputType.number,
                  validator: emptyValidator,
                  onChanged: (t) => address.number = t,
                  //onSaved: (t) => address.number = t,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: TextFormField(
                  enabled: !companyManager.loading,
                  initialValue: address.complement,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Complemento',
                    hintText: 'Opcional',
                  ),
                  onChanged: (t) => address.complement = t,
                  //onSaved: (t) => address.complement = t,
                ),
              ),
            ],
          ),
          TextFormField(
            enabled: !companyManager.loading,
            initialValue: address.district,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Bairro',
              hintText: 'Guanabara',
            ),
            validator: emptyValidator,
            onSaved: (t) => address.district = t,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: TextFormField(
                  enabled: false,
                  initialValue: address.city,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Cidade',
                    hintText: 'Campinas',
                  ),
                  validator: emptyValidator,
                  onSaved: (t) => address.city = t,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: TextFormField(
                  autocorrect: false,
                  enabled: false,
                  textCapitalization: TextCapitalization.characters,
                  initialValue: address.state,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'UF',
                    hintText: 'SP',
                    counterText: '',
                  ),
                  maxLength: 2,
                  validator: emptyValidator,
                  onSaved: (t) => address.state = t,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          if (companyManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
        ],
      );
    } else if (address.zipCode != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child:
            Text('${address.street}, ${address.number}\n${address.district}\n'
                '${address.city} - ${address.state}'),
      );
    } else {
      return Container();
    }
  }
}
