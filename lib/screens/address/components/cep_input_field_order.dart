import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../helpers/cep_formatter.dart';
import '../../../models/cart/cart_manager.dart';

class CepInputFieldOrder extends StatefulWidget {
  const CepInputFieldOrder(this.address);

  final Address address;

  @override
  _CepInputFieldOrderState createState() => _CepInputFieldOrderState();
}

class _CepInputFieldOrderState extends State<CepInputFieldOrder> {
  final TextEditingController cepController = TextEditingController();

  @override
  void dispose() {
    cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = context.watch<CartManager>();
    final primaryColor = Theme.of(context).primaryColor;
    final formater = MaskTextInputFormatter(mask: "##.###-###");

    if (widget.address.zipCode == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            enabled: !cartManager.loading,
            controller: cepController,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'CEP',
              hintText: '12.345-678',
            ),
            inputFormatters: [
              formater,
            ],
            keyboardType: TextInputType.number,
            validator: (cep) {
              if (cep!.isEmpty) {
                return 'Campo obrigatório';
              } else if (cep.length != 10) {
                return 'CEP Inválido';
              }
              return null;
            },
          ),
          // ignore: deprecated_member_use
          if (cartManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
          ElevatedButton(
            onPressed: !cartManager.loading
                ? () async {
                    if (Form.of(context).validate()) {
                      try {
                        await context
                            .read<CartManager>()
                            .getAddress(cepController.text);
                      } catch (e) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                            message: "Erro: $e",
                          ),
                        );
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              /*shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),*/
              elevation: 15.0,
              disabledForegroundColor: primaryColor.withAlpha(100),
            ),
            /*textColor: Colors.white,
            color: primaryColor,
            disabledColor: primaryColor.withAlpha(100),*/
            child: const Text('Buscar CEP'),
          ),
        ],
      );
    } else {
      String cep = CepFormatter(ponto: true).formatEditUpdate(
          widget.address.zipCode.toString(), widget.address.zipCode.toString());
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'CEP: $cep',
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            // CustomIconButton(
            //   iconData: Icons.edit,
            //   color: primaryColor,
            //   size: 20,
            //   onTap: () {
            //     context.read<CartManager>().removeAddress();
            //   },
            // ),
          ],
        ),
      );
    }
  }
}
