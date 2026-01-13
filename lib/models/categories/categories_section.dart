import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'categories_section_item.dart';

class CategoriesSection extends ChangeNotifier {
  CategoriesSection({this.id, this.name, this.type, this.items}) {
    items = items ?? [];
  }

  CategoriesSection.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document.get('name') as String?;
    type = document.get('type') as String?;
    items = (document.get('items') as List)
        .map((i) => CategoriesSectionItem.fromMap(i as Map<String, dynamic>))
        .toList();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('categories/$id');

  String? id;
  String? name;
  String? type;

  List<CategoriesSectionItem>? items;

  String? _error;
  String? get error => _error;
  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  CategoriesSection.fromMap(Map<String, dynamic> map) {
    name = map['name'] as String?;
    type = map['type'] as String?;
    items = CategoriesSectionItem.fromMap(map['items'] as Map<String, dynamic>)
        as List<CategoriesSectionItem>;
  }

  @override
  String toString() {
    return 'CategoriesSection{name: $name, type: $type}';
  }
}
