import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:fouryoupet/models/schedule/Schedule_Times.dart';

class AvailableTime extends ChangeNotifier {
  AvailableTime({
    this.id,
    this.companyID,
    this.dateSchedule,
    this.timeOfs,
    this.isBooked,
  }) {
    timeOfs = timeOfs ?? [];
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('available_times/$id');
  Reference get storageRef => storage.ref().child('available_times').child(id!);

  String? id;
  String? companyID;
  DateTime? dateSchedule;
  List<ScheduleTimes>? timeOfs; // Data e hora disponíveis
  bool? isBooked; // Indica se o horário já foi reservado

  List<Map<String, dynamic>> exportSizeList() {
    return timeOfs!.map((timeOf) => timeOf.toMap()).toList();
  }

  Future<void> delete() async {
    await firestoreRef.delete();
    notifyListeners();
  }

  Future<void> save() async {
    try {
      final Map<String, dynamic> data = {
        'companyID': companyID,
        'dateSchedule': dateSchedule,
        'timeOfs': exportSizeList(),
        'isBooked': isBooked,
      };

      if (id == null) {
        final doc = await firestore.collection('available_times').add(data);
        id = doc.id;
      } else {
        await firestoreRef.update(data);
      }
    } catch (e, s) {
      debugPrint('Erro ao salvar o horário disponível: $e :- $s');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyID': companyID,
      'dateSchedule': dateSchedule?.millisecondsSinceEpoch,
      'timeOfs': timeOfs?.map((x) => x.toMap()).toList(),
      'isBooked': isBooked,
    };
  }

  AvailableTime.fromDocument(DocumentSnapshot document) {
    try {
      id = document.id;
      companyID = document.get('companyID');

      dateSchedule = (document.get('dateSchedule') as Timestamp).toDate();
      Map<String, dynamic> dataMap = document.data() as Map<String, dynamic>;
      if (dataMap.containsKey('timeOfs')) {
        timeOfs = (document.get('timeOfs') as List)
            .map((e) => ScheduleTimes.fromMap(e))
            .toList();
      }

      isBooked = document.get('isBooked');
    } on Exception catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      //  print(id);
    }
  }

  @override
  String toString() {
    return 'AvailableTime(id: $id, companyID: $companyID, dateSchedule: $dateSchedule, timeOfDay: $timeOfs, isBooked: $isBooked)';
  }

  AvailableTime copyWith({
    ValueGetter<String?>? id,
    ValueGetter<String?>? companyID,
    ValueGetter<DateTime?>? dateSchedule,
  }) {
    return AvailableTime(
      id: id != null ? id() : this.id,
      companyID: companyID != null ? companyID() : this.companyID,
      dateSchedule: dateSchedule != null ? dateSchedule() : this.dateSchedule,
    );
  }
}
