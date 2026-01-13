import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';

import 'package:provider/provider.dart';

import 'package:flutter/services.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:validatorless/validatorless.dart';

import '../../../models/user/user_manager.dart';

class AddressInputField extends StatefulWidget {
  const AddressInputField(this.address);

  final Address address;

  @override
  State<AddressInputField> createState() => _AddressInputFieldState();
}

class _AddressInputFieldState extends State<AddressInputField> {
  final TextEditingController _controllerAdressNumber = TextEditingController();
  final TextEditingController _controllerAdressStreet = TextEditingController();
  final TextEditingController _controllerAdressDistrict =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controllerAdressStreet.text = widget.address.street ?? '';
    _controllerAdressNumber.text = widget.address.number ?? '';
    _controllerAdressDistrict.text = widget.address.district ?? '';
  }

  @override
  void dispose() {
    _controllerAdressStreet.dispose();
    _controllerAdressNumber.dispose();
    _controllerAdressDistrict.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final userManager = context.watch<UserManager>();

    String? emptyValidator(String? text) =>
        text!.isEmpty ? 'Campo obrigatório' : null;

    if (widget.address.zipCode != null || userManager.editing) {
      widget.address.checked = true;
      return Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            TextFormField(
              enabled: !userManager.loading,
              controller: _controllerAdressStreet,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Rua/Avenida',
                hintText: 'Av.Brasil',
              ),
              validator: Validatorless.required('Campo obrigatório'),
              onSaved: (t) => widget.address.street = t,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    enabled: !userManager.loading,
                    // initialValue:
                    //     userManager.editing ? widget.address.number : null,
                    controller: _controllerAdressNumber,
                    decoration: const InputDecoration(
                        isDense: true, labelText: 'Número', hintText: '123'),
                    inputFormatters: [
                      // ignore: deprecated_member_use
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    keyboardType: TextInputType.number,
                    validator: Validatorless.required('Campo obrigatório'),
                    onSaved: (t) => widget.address.number = t,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: TextFormField(
                    enabled: !userManager.loading,
                    initialValue: widget.address.complement,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Complemento',
                      hintText: 'Opcional',
                    ),
                    onSaved: (t) => widget.address.complement = t,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              enabled: !userManager.loading,
              controller: _controllerAdressDistrict,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Bairro',
                hintText: 'Guanabara',
              ),
              validator: Validatorless.required('Campo obrigatório'),
              onSaved: (t) => widget.address.district = t,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    enabled: false,
                    initialValue: widget.address.city,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Cidade',
                      hintText: 'Campinas',
                    ),
                    validator: Validatorless.required('Campo obrigatório'),
                    onSaved: (t) => widget.address.city = t,
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
                    initialValue: widget.address.state,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'UF',
                      hintText: 'SP',
                      counterText: '',
                    ),
                    maxLength: 2,
                    validator: emptyValidator,
                    onSaved: (t) => widget.address.state = t,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (userManager.loading)
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
              onPressed: !userManager.loading
                  ? () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        try {
                          context
                              .read<UserManager>()
                              .userapp!
                              .setCheckedAddress(true, -1);
                          context
                              .read<UserManager>()
                              .setAddress(widget.address);
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.success(
                              message: "Endereço salvo com sucesso",
                            ),
                          );
                          Navigator.pop(
                            context,
                          );
                        } catch (e) {
                          // ignore: deprecated_member_use
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.error(
                              message: "Erro: $e",
                            ),
                          );
                        }
                      } else {
                        showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.error(
                            message: "Campo obrigatório",
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Salvar Endereço'),
            ),
          ],
        ),
      );
    } else if (widget.address.zipCode != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
            '${widget.address.street}, ${widget.address.number}\n${widget.address.district}\n'
            '${widget.address.city} - ${widget.address.state}'),
      );
    } else {
      return Container();
    }
  }
}
