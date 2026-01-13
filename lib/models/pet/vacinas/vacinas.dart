import 'package:flutter/material.dart';

import 'vacinasaplic.dart';

class Vacinas extends ChangeNotifier {
  String? name;
  int? qtdmonth;
  List<Vacinasaplic>? aplic;

  Vacinas({this.name, this.aplic});

  Vacinas.fromMap(Map<String, dynamic> map) {
    name = map['name'] as String?;
    if (map.containsKey('qtdmonth') && map['qtdmonth'] != null) {
      qtdmonth = map['qtdmonth'] as int?;
    }
    if (map.containsKey('aplic') && map['aplic'] != null) {
      aplic =
          (map['aplic'] as List).map((e) => Vacinasaplic.fromMap(e)).toList();
    }
  }

  List<Map<String, dynamic>> exportaplicList() {
    return aplic!.map((aplic) => aplic.toMap()).toList();
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'aplic': exportaplicList()};
  }

  Vacinas clone() {
    return Vacinas(name: name, aplic: aplic);
  }
}
