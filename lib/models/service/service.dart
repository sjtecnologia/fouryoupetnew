import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/service/item_size.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:intl/intl.dart';

class Service extends ChangeNotifier {
  final Userapp? userapp;

  NumberFormat formatter = NumberFormat("00");

  Service({
    this.id,
    this.userapp,
    this.name,
    this.description,
    this.companyID,
    this.categoryid,
    this.type = false,
    this.sizes,
    this.qtdatd,
    this.deleted = false,
    this.hours,
    this.hinit,
    this.hend,
    this.hminute,
  }) {
    sizes = sizes ?? [];
    hours = hours ?? [];
  }

  Service.fromDocument(DocumentSnapshot document, {this.userapp}) {
    id = document.id;
    name = document['name'] as String? ?? '';
    description = document['description'] as String? ?? '';
    companyID = document['companyID'] as String? ?? '0';
    categoryid = document['categoryid'] as String? ?? '0';
    type = (document['type'] ?? false) as bool;
    qtdatd = document['qtdatd'] as int? ?? 0;

    Map<String, dynamic> dataMap = document.data() as Map<String, dynamic>;
    if (dataMap.containsKey('hours')) {
      if (document.get('hours') != null) {
        hours = List<String>.from(document.get('hours') as List<dynamic>);
      }
    } else {
      hours = [];
    }

    deleted = (document.get('deleted') ?? false) as bool;
    sizes = (document.get('sizes') as List<dynamic>? ?? [])
        .map((s) => ItemSize.fromMap(s as Map<String, dynamic>))
        .toList();
    hminute = (document['hminute'] ?? 0) as int;
    hinit = (document['hinit'] ?? 0) as int;
    hend = (document['hend'] ?? 0) as int;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('services/$id');
  Reference get storageRef => storage.ref().child('services').child(id!);

  String? id;
  String? name;
  String? description;
  String? companyID;
  String? categoryid;
  int? qtdatd = 1;
  bool? type;

  List<ItemSize>? sizes;

  List<String>? hours;
  List<dynamic>? newHours;
  bool? deleted;

  int? hinit = 0;
  int? hend = 0;
  int? hminute = 0;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ItemSize? _selectedSize;
  ItemSize? get selectedSize => _selectedSize;

  set selectedSize(ItemSize? value) {
    _selectedSize = value;
    notifyListeners();
  }

  num? get basePrice {
    num? lowest = double.infinity;
    for (final size in sizes!) {
      if (size.price! < lowest!) {
        lowest = size.price;
      }
    }
    return lowest;
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

  ItemSize? findSize(String? name) {
    try {
      return sizes!.firstWhere((s) => s.name == name);
    } catch (e) {
      return null;
    }
  }

  String toJson() => json.encode(toMap());

  factory Service.fromJson(String source) {
    return Service.fromMap((json.decode(source)));
  }

  List<Map<String, dynamic>> exportSizeList() {
    return sizes!.map((size) => size.toMap()).toList();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'companyID': companyID,
      'categoryid': categoryid,
      'type': type,
      'hend': hend,
      'hinit': hinit,
      'hminute': hminute,
      'hours': hours,
      'sizes': sizes?.map((x) => x.toMap()).toList(),
      'qtdatd': qtdatd,
      'deleted': deleted,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      companyID: map['companyID'] != null ? map['companyID'] as String : null,
      categoryid:
          map['categoryid'] != null ? map['categoryid'] as String : null,
      type: map['type'] != null ? map['type'] as bool : null,
      hours: map['hours'] != null
          ? (map['hours'] as List).map<String>((hours) => hours).toList()
          : null,
      sizes: map['sizes'] != null
          ? (map['sizes'] as List).map((s) => ItemSize.fromMap(s)).toList()
          : null,
      deleted: map['deleted'] != null ? map['deleted'] as bool : null,
    );
  }

  Future<void> save() async {
    loading = true;
    if (type == null) type = false;
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'companyID': companyID,
      'categoryid': categoryid,
      'qtdatd': qtdatd,
      'type': type,
      'sizes': exportSizeList(),
      'deleted': deleted,
      'hinit': hinit,
      'hend': hend,
      'hminute': hminute,
      'keywords': _generateKeywords(name! + '' + description!),
    };

    if (id == null) {
      final doc = await firestore.collection('services').add(data);
      id = doc.id;
    } else {
      await firestoreRef.update(data);
    }

    final List<String> updateHours = [];

    if (hinit != 0 && hend != 0 && hminute != 0) {
      for (int i = hinit!.toInt(); i <= hend!.toInt(); i++) {
        for (int x = 0; x < 60;) {
          updateHours.add(formatter.format(i) + ':' + formatter.format(x));
          if (i == hend) {
            x = 60;
          }
          x = x + hminute!.toInt();
        }
      }
    }
    await firestoreRef.update({'hours': updateHours});

    hours = updateHours;
    loading = false;
  }

  void delete() {
    firestoreRef.update({'deleted': true});
  }

  Service clone() {
    return Service(
      userapp: userapp,
      id: id,
      name: name,
      companyID: companyID,
      categoryid: categoryid,
      description: description,
      qtdatd: qtdatd,
      type: type,
      hours: List.from(hours!),
      sizes: sizes!.map((size) => size.clone()).toList(),
      deleted: deleted,
      hinit: hinit,
      hend: hend,
      hminute: hminute,
    );
  }

  @override
  String toString() {
    return 'Service{id: $id, name: $name, description: $description, qtdatd: $qtdatd, companyID: $companyID, categoryid: $categoryid, type: $type, sizes: $sizes,  hours: $hours, newHours: $newHours, hinit: $hinit, hminute: $hminute, hend: $hend}';
  }
}
