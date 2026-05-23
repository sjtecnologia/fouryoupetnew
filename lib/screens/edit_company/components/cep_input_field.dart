// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import 'package:fouryoupet/common/custom_icon_button.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CepInputField extends StatefulWidget {
  const CepInputField(
    this.address,
  );

  final Address address;

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
    final companyManager = context.watch<CompanyManager>();
    final primaryColor = Theme.of(context).primaryColor;
    final formater = MaskTextInputFormatter(mask: "##.###-###");

    if (widget.address.zipCode == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            enabled: !companyManager.loading,
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
          if (companyManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
          ElevatedButton(
            onPressed: !companyManager.loading
                ? () async {
                    companyManager.loading = true;
                    setState(() {});
                    //if (Form.of(context).validate()) {
                    try {
                      await context
                          .read<CompanyManager>()
                          .getAddress(cepController.text);
                    } catch (e) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Erro: $e",
                        ),
                      );
                    }
                    setState(() {});
                  }
                // }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 15.0,
              disabledForegroundColor: primaryColor.withAlpha(100),
            ),
            child: const Text('Buscar CEP'),
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'CEP: ${widget.address.zipCode}',
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            CustomIconButton(
              iconData: Icons.edit,
              color: primaryColor,
              size: 20,
              onTap: () async {
                await context.read<CompanyManager>().removeAddress();
              },
            ),
          ],
        ),
      );
    }
  }
}
