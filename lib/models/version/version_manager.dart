import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VersionManager extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  VersionManager() {
    findVersion();
  }

  String version = '';
  Future<String> findVersion() async {
    final QuerySnapshot snapVersion =
        await firestore.collection('version').get();
    return version = snapVersion.docs.first.id;
    //snapProducts.docs.map((d) => VersionApp.fromDocument(d)).toString();
  }

  String versionios = '';
  Future<String> findVersionIos() async {
    final QuerySnapshot snapVersionios =
        await firestore.collection('versionios').get();
    return versionios = snapVersionios.docs.first.id;
    //snapProducts.docs.map((d) => VersionApp.fromDocument(d)).toString();
  }
}
