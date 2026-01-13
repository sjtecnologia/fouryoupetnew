import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:fouryoupet/models/pet/pet_manager.dart';
import 'package:fouryoupet/models/pet/vacinas/vacinasaplic.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../../../models/pet/pet.dart';
import '../../../../models/pet/vacinas/vacinas.dart';

class VacinaInputField extends StatelessWidget {
  const VacinaInputField(this.pet, this.vacinas, this.editing);

  final Pet pet;
  final Vacinas? vacinas;
  final bool? editing;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final petManager = context.watch<PetManager>();

    Vacinas vacinasnew = Vacinas();
    Vacinasaplic aplic = Vacinasaplic();

    if (vacinas != null) vacinasnew = vacinas!;

    String? emptyValidator(String? text) =>
        text!.isEmpty ? 'Campo obrigatório' : null;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          style: TextStyle(
              color: Color.fromARGB(255, 255, 111, 0),
              fontWeight: FontWeight.bold),
          enabled: !petManager.loading,
          initialValue: vacinas != null ? vacinasnew.name : null,
          decoration: const InputDecoration(
              isDense: true,
              labelText: 'Nome da Vacina',
              labelStyle: TextStyle(
                color: const Color.fromARGB(255, 255, 111, 0),
              )),
          validator: emptyValidator,
          onSaved: (t) => vacinasnew.name = t,
        ),
        const SizedBox(
          height: 16,
        ),
        FormBuilderDateTimePicker(
          validator: (dtapli) {
            if (dtapli == null) {
              return 'Deve ser informada a data de aplicação';
            }
            return null;
          },
          name: 'DataAplic',
          style: TextStyle(
              color: Color.fromARGB(255, 255, 111, 0),
              fontWeight: FontWeight.bold),
          initialValue: (vacinasnew.aplic?.first.dataaplicacao),
          fieldHintText: 'Data de Aplicação da Vacina',
          locale: Locale('pt', 'BR'),
          inputType: InputType.date,
          format: DateFormat('dd/MM/yyyy'),
          fieldLabelText: 'Data de Aplicação da Vacina',
          decoration: InputDecoration(
            label: Text(
              'Data de Aplicação da Vacina',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 111, 0),
              ),
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.calendar_today_sharp,
              color: Color.fromARGB(255, 255, 111, 0),
            ),
          ),
          onChanged: (dtaplic) {
            vacinasnew.aplic?.last.aplicatednew = true;
            vacinasnew.aplic?.last.dtaplicnews = null;
            if (vacinasnew.aplic?.last.dataaplicacao != dtaplic) {
              aplic.aplicated = true;
              aplic.dataaplicacao = dtaplic;
              aplic.dtaplicnews = dtaplic;
            }
            vacinasnew.aplic?.add(aplic);
          },
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
                      if (this.pet.vacinas == null && this.vacinas == null)
                        this.pet.vacinas = [];
                      if (this.pet.vacinas!.last.aplic == null)
                        this.pet.vacinas!.last.aplic = [];
                      // if (this.vacinas != null)
                      //   this.pet.vacinas!.remove(this.vacinas);
                      if (!editing!) vacinasnew.aplic = <Vacinasaplic>[];
                      if (aplic.dataaplicacao != null)
                        vacinasnew.aplic!.add(aplic);
                      //this.pet.vacinas!.add(vacinasnew);
                      if (!editing!) {
                        this.pet.vacinas!.add(vacinasnew);
                      } else {
                        this
                            .pet
                            .vacinas
                            ?.firstWhere((e) => e.name == vacinas?.name)
                            .name = vacinasnew.name;
                        // this
                        //     .pet
                        //     .vacinas
                        //     ?.firstWhere((e) => e.name == vacinas?.name)
                        //     .aplic
                        //     ?.add(aplic);
                      }

                      context.read<PetManager>().setVacinas(pet);
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          message: "Vacinação salva com sucesso",
                        ),
                      );
                    } catch (e) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Erro: $e",
                        ),
                      );
                    }
                  }
                  Navigator.pop(
                    context,
                  );
                }
              : null,
          child: const Text('Salvar Vacinação'),
        ),
      ],
    );
  }
}
