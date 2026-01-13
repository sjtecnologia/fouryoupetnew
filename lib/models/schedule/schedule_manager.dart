import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/schedule/AvailableTime.dart';

class ScheduleManager extends ChangeNotifier {
  // ignore: unused_field
  AvailableTime? _availableTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AvailableTime>? availableTimes;

  Future<void> saveAvailableTime(AvailableTime availableTime) async {
    try {
      _availableTime = availableTime;
      _availableTime?.save();

      print('Horário disponível salvo com sucesso!');
    } catch (e, s) {
      print('Erro ao salvar o horário disponível: $e :- $s');
    }
  }

  Future<void> delete(AvailableTime availableTime) async {
    _availableTime = availableTime;
    _availableTime?.delete();
    notifyListeners();
  }

  Future<void> update(AvailableTime availableTime) async {
    _availableTime = availableTime;
    _availableTime?.delete();
    saveAvailableTime(availableTime);
    notifyListeners();
  }

  Future<List<AvailableTime>?> loadTimes(
      String companyID, DateTime dateScheule) async {
    try {
      final QuerySnapshot snapProducts = await _firestore
          .collection('available_times')
          .where('companyID', isEqualTo: companyID)
          .where('dateSchedule', isEqualTo: dateScheule)
          .get()
          .timeout(Duration(seconds: 10));
      availableTimes =
          snapProducts.docs.map((d) => AvailableTime.fromDocument(d)).toList();
      // print(availableTimes?.first);
    } catch (e, s) {
      log('Erro ao buscar agenda', error: e, stackTrace: s);
      return null;
    }
    return availableTimes;
  }
}
