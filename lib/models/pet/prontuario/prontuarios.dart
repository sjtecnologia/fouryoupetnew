// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Prontuarios {
  String? descricao;
  String? observacao;
  DateTime? dataprocedimento;
  DateTime? dataretorno;
  bool? finalizado;
  String? scheduledID;
  Prontuarios({
    this.descricao,
    this.observacao,
    this.dataprocedimento,
    this.dataretorno,
    this.finalizado,
    this.scheduledID,
  });

  Prontuarios.fromMap(Map<String, dynamic> map) {
    descricao = map['descricao'] as String?;
    observacao = map['observacao'] as String?;
    dataprocedimento = (map['dataprocedimento'] != null
        ? (map['dataprocedimento'] as Timestamp).toDate()
        : DateTime.now());
    //dataprocedimento = (map['dataprocedimento'] as Timestamp).toDate();
    dataretorno = (map['dataretorno'] != null
        ? (map['dataretorno'] as Timestamp).toDate()
        : DateTime.now());
    //dataretorno = (map['dataretorno'] as Timestamp).toDate();
    finalizado = map['finalizado'] as bool?;
    scheduledID =
        (map['scheduledID'] != null ? (map['scheduledID'] as String?) : '');
  }

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'observacao': observacao,
      'dataprocedimento': dataprocedimento,
      'dataretorno': dataretorno,
      'finalizado': finalizado,
      'scheduledID': scheduledID,
    };
  }

  Prontuarios copyWith({
    String? descricao,
    String? observacao,
    DateTime? dataprocedimento,
    DateTime? dataretorno,
    bool? finalizado,
    String? scheduledID,
  }) {
    return Prontuarios(
      descricao: descricao ?? this.descricao,
      observacao: observacao ?? this.observacao,
      dataprocedimento: dataprocedimento ?? this.dataprocedimento,
      dataretorno: dataretorno ?? this.dataretorno,
      finalizado: finalizado ?? this.finalizado,
      scheduledID: scheduledID ?? this.scheduledID,
    );
  }
}
