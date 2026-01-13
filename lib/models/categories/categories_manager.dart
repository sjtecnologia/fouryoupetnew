import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'categories_section.dart';

class CategoriesManager extends ChangeNotifier {
  CategoriesManager() {
    _loadSections();
  }

  final List<CategoriesSection> _sections = [];

  CategoriesSection? findCategoriesSectionByID(String? id) {
    try {
      return _sections.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  bool loading = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _loadSections() async {
    firestore
        .collection('categories')
        .orderBy('items', descending: false)
        .snapshots()
        .listen((snapshot) {
      _sections.clear();
      for (final DocumentSnapshot document in snapshot.docs) {
        _sections.add(CategoriesSection.fromDocument(document));
      }
      notifyListeners();
    });
  }

  List<CategoriesSection> get sections {
    return _sections;
  }
}
