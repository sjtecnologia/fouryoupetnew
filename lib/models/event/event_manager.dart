import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:fouryoupet/models/event/event.dart';

class EventManager extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<AppEvent> allEvent = [];
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    //notifyListeners();
  }

  Future<List<AppEvent>> loadAllAppEvent(
      bool? type, DateTime event_date, String companyID) async {
    loading = true;

    allEvent.clear();
    final QuerySnapshot snapEvents = await firestore
        .collection('events')
        .where('type', isEqualTo: type)
        .where('event_date', isGreaterThanOrEqualTo: event_date)
        .where('event_date', isLessThanOrEqualTo: event_date)
        .where('companyID', isEqualTo: companyID)
        .get();
    allEvent.add(snapEvents.docs.map((d) => AppEvent.fromDocument(d)).first);

    for (var cp
        in (snapEvents.docs.map((d) => AppEvent.fromDocument(d)).toList())) {
      allEvent.add(cp);
    }

    loading = false;
    return allEvent;
  }
}
