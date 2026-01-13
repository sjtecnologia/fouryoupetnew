import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

class Banner extends ChangeNotifier {
  List<String>? images;
  String? id;
  Banner({this.images, this.id}) {
    images = images ?? [];
  }
  Banner.fromDocument(DocumentSnapshot document, {this.images}) {
    id = document.id;
    images = List<String>.from(document.get('images') as List<dynamic>);
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('banner/0');
  Reference get storageRef => storage.ref().child('banner').child('0');
}
