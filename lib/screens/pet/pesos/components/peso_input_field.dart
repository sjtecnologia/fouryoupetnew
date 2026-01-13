import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:fouryoupet/models/pet/pet_manager.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../../models/pet/pesos/pesos.dart';
import '../../../../models/pet/pet.dart';

class PesoInputField extends StatelessWidget {
  const PesoInputField(this.pet, this.pesos);

  final Pet pet;
  final Pesos? pesos;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final petManager = context.watch<PetManager>();

    Pesos pesosnew = Pesos();

    if (pesos != null) pesosnew = this.pesos!;

    String? emptyValidator(String? text) =>
        text!.isEmpty ? 'Campo obrigatório' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          enabled: !petManager.loading,
          initialValue: pesos != null ? pesosnew.peso : null,
          decoration: const InputDecoration(
            isDense: true,
            labelText: 'Peso do Pet',
          ),
          validator: emptyValidator,
          onSaved: (t) => pesosnew.peso = t,
        ),
        const SizedBox(
          height: 16,
        ),
        FormBuilderDateTimePicker(
          //firstDate: DateTime.now(),
          //alwaysUse24HourFormat: true,
          validator: (datapeso) {
            if (datapeso == null) {
              return 'Deve ser informada a data da pesagem';
            }
            return null;
          },
          name: 'datapeso',
          style: TextStyle(
            color: Colors.black,
          ),
          initialValue: pesos != null ? (pesosnew.datapeso) : null,
          fieldHintText: 'Data da Pesagem',
          locale: Locale('pt', 'BR'),
          inputType: InputType.date,
          format: DateFormat('dd/MM/yyyy'),
          fieldLabelText: 'Data da Pesagem',
          decoration: InputDecoration(
            label: Text(
              'Data da Pesagem',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.calendar_today_sharp,
              color: Colors.grey,
            ),
          ),
          onSaved: (datapeso) => pesosnew.datapeso = datapeso,
        ),
        const SizedBox(
          height: 16,
        ),
        if (petManager.loading)
          LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation(primaryColor),
            backgroundColor: Colors.transparent,
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                Theme.of(context).primaryColor.withAlpha(100),
          ),
          onPressed: !petManager.loading
              ? () async {
                  if (Form.of(context).validate()) {
                    Form.of(context).save();

                    try {
                      if (this.pet.pesos == null && this.pesos == null)
                        this.pet.pesos = [];
                      if (this.pesos != null)
                        this.pet.pesos!.remove(this.pesos);
                      this.pet.pesos!.add(pesosnew);
                      context.read<PetManager>().setPesos(pet);
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          message: "Peso salvo com sucesso",
                        ),
                      );
                      Navigator.pop(
                        context,
                      );
                    } catch (e) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Erro :$e",
                        ),
                      );
                    }
                  }
                  // showTopSnackBar(
                  //   Overlay.of(context),
                  //   CustomSnackBar.error(
                  //     message: "Erro ",
                  //   ),
                  // );
                  //
                }
              : null,
          child: const Text('Salvar Pesagem'),
        ),
      ],
    );
  }
}
