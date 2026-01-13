import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/helpers/custom_icon_button.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../helpers/cep_formatter.dart';

class CepInputField extends StatefulWidget {
  const CepInputField(this.address);

  final Address? address;

  @override
  _CepInputFieldState createState() => _CepInputFieldState();
}

class _CepInputFieldState extends State<CepInputField> {
  final TextEditingController cepController = TextEditingController();

  @override
  void dispose() {
    cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>();
    final primaryColor = Theme.of(context).primaryColor;
    final formater = MaskTextInputFormatter(mask: "##.###-###");
    String cep = '';
    if (widget.address!.zipCode == null || userManager.editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            enabled: !userManager.loading,
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
          if (userManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
          ElevatedButton(
            onPressed: !userManager.loading
                ? () async {
                    if (Form.of(context).validate()) {
                      try {
                        await context
                            .read<UserManager>()
                            .getAddress(cepController.text);
                        setState(() {});
                      } catch (e) {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
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
      if (widget.address != null) {
        cep = CepFormatter(ponto: true).formatEditUpdate(
            widget.address!.zipCode.toString(),
            widget.address!.zipCode.toString());
      }
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
            CustomIconButton(
              iconData: Icons.edit,
              color: primaryColor,
              size: 20,
              onTap: () async {
                userManager.editing = false;
                await Navigator.of(context)
                    .pushNamed('/addadress', arguments: Address());
                //context.read<UserManager>().removeAddress(widget.address);
              },
            ),
          ],
        ),
      );
    }
  }
}
