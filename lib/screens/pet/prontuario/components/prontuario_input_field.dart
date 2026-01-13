import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:fouryoupet/models/pet/pet_manager.dart';
import 'package:fouryoupet/models/pet/prontuario/prontuarios.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../../models/pet/pet.dart';

class ProntuarioInputField extends StatelessWidget {
  const ProntuarioInputField(this.pet, this.prontuarios);

  final Pet pet;
  final Prontuarios? prontuarios;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final petManager = context.watch<PetManager>();

    Prontuarios prontuariosnew = Prontuarios();

    if (prontuarios != null) prontuariosnew = this.prontuarios!;

    String? emptyValidator(String? text) =>
        text!.isEmpty ? 'Campo obrigatório' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          enabled: !petManager.loading,
          initialValue: prontuarios != null ? prontuariosnew.descricao : null,
          decoration: const InputDecoration(
            isDense: true,
            labelText: 'Descrião do Procedimento',
          ),
          validator: emptyValidator,
          onSaved: (t) => prontuariosnew.descricao = t,
        ),
        const SizedBox(
          height: 16,
        ),
        TextFormField(
          enabled: !petManager.loading,
          initialValue: prontuariosnew.observacao,
          decoration: const InputDecoration(
            isDense: true,
            labelText: 'Observação',
          ),
          validator: emptyValidator,
          onSaved: (t) => prontuariosnew.observacao = t,
        ),
        const SizedBox(
          height: 16,
        ),
        FormBuilderDateTimePicker(
          //firstDate: DateTime.now(),
          //alwaysUse24HourFormat: true,
          validator: (dataaplicacao) {
            if (dataaplicacao == null) {
              return 'Deve ser informada a data de execução';
            }
            return null;
          },
          name: 'dataaplicacao',
          style: TextStyle(
            color: Colors.black,
          ),
          initialValue:
              prontuarios != null ? (prontuariosnew.dataprocedimento) : null,
          fieldHintText: 'Data do Procedimento',
          locale: Locale('pt', 'BR'),
          inputType: InputType.date,
          format: DateFormat('dd/MM/yyyy'),
          fieldLabelText: 'Data do Procedimento',
          decoration: InputDecoration(
            label: Text(
              'Data do Procedimento',
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
          onSaved: (dataaplicacao) =>
              prontuariosnew.dataprocedimento = dataaplicacao,
        ),
        const SizedBox(
          height: 16,
        ),
        FormBuilderDateTimePicker(
          //firstDate: DateTime.now(),
          //alwaysUse24HourFormat: true,
          validator: (dataproxima) {
            if (dataproxima == null) {
              return 'Deve ser informada a data do retorno do Procedimento';
            }
            return null;
          },
          name: 'dataproxima',
          style: TextStyle(
            color: Colors.black,
          ),
          initialValue:
              prontuarios != null ? (prontuariosnew.dataretorno) : null,
          fieldHintText: 'Data do retorno',
          locale: Locale('pt', 'BR'),
          inputType: InputType.date,
          format: DateFormat('dd/MM/yyyy'),
          fieldLabelText: 'Data do retorno',
          decoration: InputDecoration(
            label: Text(
              'Data do retorno',
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
          onSaved: (dataproxima) =>
              prontuariosnew.dataretorno = dataproxima ?? DateTime.now(),
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
                      if (this.pet.prontuarios == null &&
                          this.prontuarios == null) this.pet.prontuarios = [];
                      if (this.prontuarios != null)
                        this.pet.prontuarios!.remove(this.prontuarios);
                      this.pet.prontuarios!.add(prontuariosnew);
                      context.read<PetManager>().setProntuarios(pet);
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          message: "Protuário salvo com sucesso",
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
          child: const Text('Salvar Prontuário'),
        ),
      ],
    );
  }
}
