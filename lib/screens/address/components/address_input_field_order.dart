import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddressInputFieldOrder extends StatelessWidget {
  const AddressInputFieldOrder(this.address);

  final Address address;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cartManager = context.watch<CartManager>();

    String? emptyValidator(String? text) =>
        text!.isEmpty ? 'Campo obrigatório' : null;

    // cartManager.calculateDeliverynew(cartManager.user?.address?.where((a) => a.checked == true).first.lat?? 0,
    // cartManager.user?.address?.where((a) => a.checked == true).first.long?? 0,
    // cartManager.items.first.companyID?? '');

    if (address.zipCode == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            enabled: !cartManager.loading,
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
                  enabled: !cartManager.loading,
                  initialValue: address.number,
                  decoration: const InputDecoration(
                      isDense: true, labelText: 'Número', hintText: '123'),
                  inputFormatters: [
                    // ignore: deprecated_member_use
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  keyboardType: TextInputType.number,
                  validator: emptyValidator,
                  onSaved: (t) => address.number = t,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: TextFormField(
                  enabled: !cartManager.loading,
                  initialValue: address.complement,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Complemento',
                    hintText: 'Opcional',
                  ),
                  onSaved: (t) => address.complement = t,
                ),
              ),
            ],
          ),
          TextFormField(
            enabled: !cartManager.loading,
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
          if (cartManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
          // ignore: deprecated_member_use
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  Theme.of(context).primaryColor.withAlpha(100),
            ),
            onPressed: !cartManager.loading
                ? () async {
                    if (Form.of(context).validate()) {
                      Form.of(context).save();

                      try {
                        await context.read<CartManager>().setAddress(address);
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                            message: "Endereço salvo com sucesso",
                          ),
                        );
                      } catch (e) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: 'Erro: $e',
                          ),
                        );
                      }
                    }
                  }
                : null,
            child: const Text('Salvar Endereço'),
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
