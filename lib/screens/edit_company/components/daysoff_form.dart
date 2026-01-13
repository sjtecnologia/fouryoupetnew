import 'package:flutter/material.dart';

import '../../../models/company/company.dart';

class DaysOffForm extends StatefulWidget {
  const DaysOffForm({Key? key, required this.company}) : super(key: key);
  final Company company;

  @override
  State<DaysOffForm> createState() => _DaysOffFormState();
}

class _DaysOffFormState extends State<DaysOffForm> {
  final horainiEC = TextEditingController();
  final horafimEC = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    horainiEC.dispose();
    horafimEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, bool> h = {};
    List<String>? sh = widget.company.daysoff;
    String? ht = '';
    String? st = '';
    String? htsub = '';

    sh!.sort();
    h.clear();
    for (int i = 1; i <= 7; i++) {
      switch (i) {
        case 1:
          st = '   Segunda - Feira';
          break;
        case 2:
          st = '   Terça - Feira';
          break;
        case 3:
          st = '   Quarta - Feira';
          break;
        case 4:
          st = '   Quinta - Feira';
          break;
        case 5:
          st = '   Sexta - Feira';
          break;
        case 6:
          st = '   Sábado';
          break;
        case 7:
          st = '   Domingo';
          break;
        default:
      }
      ht = i.toString();
      ht = ht + st!;
      htsub = ht.substring(0, 1);
      if (sh.contains(htsub))
        h.addAll({ht: true});
      else
        h.addAll({ht: false});
    }

    sh.clear;

    return FormField<List<String>>(
        initialValue: List.from(sh),
        onSaved: (daysoff) {
          widget.company.daysoff = daysoff;
        },
        builder: (state) {
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 1,
            runSpacing: 1,
            children: h.keys.map((String key) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: new CheckboxListTile(
                      title: new Text(key),
                      value: h[key],
                      onChanged: (bool? check) {
                        if (check != null && check == true) {
                          state.value!.add(key.substring(0, 1));
                        } else {
                          state.value!.remove(key.substring(0, 1));
                        }

                        state.didChange(state.value);
                        h[key] = check!;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              );
            }).toList(),
          );
        });
  }
}
