import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/service/service.dart';

class HoursForm extends StatelessWidget {
  const HoursForm({Key? key, required this.service}) : super(key: key);
  final Service service;
  @override
  Widget build(BuildContext context) {
    Map<String, bool> h = {};
    List<String>? sh = service.hours;
    int? shinit = service.hinit ?? 0;
    int? shend = service.hend ?? 0;
    int? shminute = service.hminute ?? 0;
    String? ht = '';

    NumberFormat formatter = NumberFormat("00");

    sh?.sort();
    h.clear();
    for (int i = shinit; i <= shend; i++) {
      for (int x = 0; x < 60;) {
        ht = formatter.format(i) + ':' + formatter.format(x);
        h.addAll({ht: true});
        x = x + shminute;
        if (i == shend) {
          x = 60;
        }
      }
    }

    sh!.forEach((s) {
      h.update(s, (value) => true);
    });

    return FormField<List<dynamic>>(
        initialValue: List.from(sh),
        validator: (hours) {
          if (hours!.isEmpty) {
            return 'Insira ao menos um horário';
          }
          return null;
        },
        onSaved: (hours) => service.newHours = hours,
        builder: (state) {
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: h.keys.map((String key) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: new CheckboxListTile(
                  title: new Text(key + ' h'),
                  value: h[key],
                  onChanged: (bool? check) {
                    if (check != null && check == true) {
                      state.value!.add(key);
                    } else {
                      state.value!.remove(key);
                    }

                    state.didChange(state.value);
                    h[key] = check!;
                  },
                ),
              );
            }).toList(),
          );
        });
  }
}
