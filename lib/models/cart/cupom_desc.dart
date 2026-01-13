// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:fouryoupet/models/categories/categories_section.dart';

class CupomDesc extends ChangeNotifier {
  String companyID;
  String name;
  num? porcent;
  num? valor;
  List<CategoriesSection> category;
  DateTime dataini;
  DateTime datafim;
  CupomDesc({
    required this.companyID,
    required this.name,
    this.porcent,
    this.valor,
    required this.category,
    required this.dataini,
    required this.datafim,
  });

  CupomDesc copyWith({
    String? companyID,
    String? name,
    num? porcent,
    num? valor,
    List<CategoriesSection>? category,
    DateTime? dataini,
    DateTime? datafim,
  }) {
    return CupomDesc(
      companyID: companyID ?? this.companyID,
      name: name ?? this.name,
      porcent: porcent ?? this.porcent,
      valor: valor ?? this.valor,
      category: category ?? this.category,
      dataini: dataini ?? this.dataini,
      datafim: datafim ?? this.datafim,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'companyID': companyID,
      'name': name,
      'porcent': porcent,
      'valor': valor,
      'category': category.map((x) => x.toMap()).toList(),
      'dataini': dataini.millisecondsSinceEpoch,
      'datafim': datafim.millisecondsSinceEpoch,
    };
  }

  factory CupomDesc.fromMap(Map<String, dynamic> map) {
    return CupomDesc(
      companyID: map['companyID'] as String,
      name: map['name'] as String,
      porcent: map['porcent'] != null ? map['porcent'] as num : null,
      valor: map['valor'] != null ? map['valor'] as num : null,
      category: List<CategoriesSection>.from(
        (map['category'] as List<int>).map<CategoriesSection>(
          (x) => CategoriesSection.fromMap(x as Map<String, dynamic>),
        ),
      ),
      dataini: DateTime.fromMillisecondsSinceEpoch(map['dataini'] as int),
      datafim: DateTime.fromMillisecondsSinceEpoch(map['datafim'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory CupomDesc.fromJson(String source) =>
      CupomDesc.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CupomDesc(companyID: $companyID, name: $name, porcent: $porcent, valor: $valor, category: $category, dataini: $dataini, datafim: $datafim)';
  }

  @override
  bool operator ==(covariant CupomDesc other) {
    if (identical(this, other)) return true;

    return other.companyID == companyID &&
        other.name == name &&
        other.porcent == porcent &&
        other.valor == valor &&
        listEquals(other.category, category) &&
        other.dataini == dataini &&
        other.datafim == datafim;
  }

  @override
  int get hashCode {
    return companyID.hashCode ^
        name.hashCode ^
        porcent.hashCode ^
        valor.hashCode ^
        category.hashCode ^
        dataini.hashCode ^
        datafim.hashCode;
  }
}
