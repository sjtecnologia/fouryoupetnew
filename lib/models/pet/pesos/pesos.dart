// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Pesos {
  String? peso;

  DateTime? datapeso;

  Pesos({
    this.peso,
    this.datapeso,
  });

  Pesos.fromMap(Map<String, dynamic> map) {
    peso = map['peso'] as String?;

    datapeso = (map['datapeso'] != null
        ? (map['datapeso'] as Timestamp).toDate()
        : DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'peso': peso,
      'datapeso': datapeso,
    };
  }

  Pesos copyWith({
    String? peso,
    DateTime? datapeso,
  }) {
    return Pesos(
      peso: peso ?? this.peso,
      datapeso: datapeso ?? this.datapeso,
    );
  }
}
