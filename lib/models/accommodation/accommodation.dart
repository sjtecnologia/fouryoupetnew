// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Accommodation extends ChangeNotifier {
  Accommodation({
    this.id,
    this.name,
    this.description,
    this.companyID,
    this.categoryid,
    this.deleted,
    this.price,
    this.qtdatd,
  });

  NumberFormat formatter = NumberFormat("00");

  Accommodation.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] ?? '';
    description = document['description'] ?? '';
    companyID = document['companyID'] ?? '';
    categoryid = document['categoryid'] ?? '';
    deleted = (document.get('deleted') ?? false) as bool;
    qtdatd = document['qtdatd'] ?? 0;

    price = document['price'] ?? 0.00;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('accommodation/$id');
  Reference get storageRef => storage.ref().child('accommodation').child(id!);

  String? id;
  String? name;
  String? description;
  String? companyID;
  String? categoryid;
  bool? deleted;
  num? price;
  int? qtdatd;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String toJson() => json.encode(toMap());

  factory Accommodation.fromJson(String source) {
    return Accommodation.fromMap((json.decode(source)));
  }

  // Função para gerar as keywords
  List<String> _generateKeywords(String text) {
    final words = removeDiacritics(text).toLowerCase().split(' ');
    final keywords = <String>[];
    for (var word in words) {
      for (var i = 0; i < word.length; i++) {
        for (var j = i + 1; j <= word.length; j++) {
          keywords.add(word.substring(i, j));
        }
      }
    }
    return keywords;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'companyID': companyID,
      'categoryid': categoryid,
      'qtdatd': qtdatd,
      'deleted': deleted,
    };
  }

  factory Accommodation.fromMap(Map<String, dynamic> map) {
    return Accommodation(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      companyID: map['companyID'] != null ? map['companyID'] as String : null,
      categoryid:
          map['categoryid'] != null ? map['categoryid'] as String : null,
      deleted: map['deleted'] != null ? map['deleted'] as bool : null,
    );
  }

  Future<void> save() async {
    loading = true;
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'companyID': companyID,
      'categoryid': categoryid,
      'deleted': deleted ?? false,
      'price': price ?? 0,
      'qtdatd': qtdatd ?? 1,
      'keywords': _generateKeywords(name! + ' ' + description!),
    };

    if (id == null) {
      final doc = await firestore.collection('accommodation').add(data);
      id = doc.id;
    } else {
      await firestoreRef.update(data);
    }

    loading = false;
  }

  void delete() {
    firestoreRef.update({'deleted': true});
  }

  Accommodation clone() {
    return Accommodation(
        id: id,
        name: name,
        companyID: companyID,
        categoryid: categoryid,
        description: description,
        deleted: deleted,
        price: price,
        qtdatd: qtdatd);
  }
}
