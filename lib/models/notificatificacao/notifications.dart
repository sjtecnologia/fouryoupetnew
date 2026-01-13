// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/notificatificacao/notifi.dart';

class Notifications extends ChangeNotifier {
  String? id;
  List<Notifi>? notif;

  Notifications({
    this.notif,
  });

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentReference get firestoreRef => firestore.doc('notifications/$id');

  Future<void> excluir() async {
    try {
      firestoreRef.delete();
    } catch (e) {
      debugPrint('Erro ao deletar');
      return Future.error('Falha ao deletar');
    }
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Notifications.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    Map<String, dynamic> dataMap = doc.data() as Map<String, dynamic>;
    if (dataMap.containsKey('notifi')) {
      notif =
          (doc.get('notifi') as List).map((e) => Notifi.fromMap(e)).toList();
      notif?.sort((a, b) => b.notificationDate!.compareTo(a.notificationDate!));
    }
  }

  List<Map<String, dynamic>> exportNotifisList() {
    return notif!.map((notifi) => notifi.toMap()).toList();
  }

  Future<void> saveData() async {
    //final userapp = await UserManager().finduser();
    id = id;
    await firestoreRef.set(toMap());
  }

  Future<void> updatenf(Notifications? notifi) async {
    id = notifi?.id;
    this.notif = notifi?.notif;
    saveData();
  }

  Map<String, dynamic> toMap() {
    final retorno = {
      'id': id,
      if (this.notif != null) 'notifi': exportNotifisList(),
    };

    return retorno;
  }

  void setNotifi(Notifi notifi) async {
    if (notif == null) notif = <Notifi>[];
    notif!.add(notifi);

    await saveData();
  }
}
