import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/schedule/AvailableTime.dart';

import 'package:fouryoupet/models/service/service.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:intl/intl.dart';

import '../event/event.dart';

class ServiceManager extends ChangeNotifier {
  List<Service> services = [];
  NumberFormat formatter = NumberFormat("00");

  Userapp? user;

  Service? service;

  final List<AppEvent> _events = [];
  List<AppEvent> get events => _events;

  final List<String> _hfree = [];
  List<String> get hfree => _hfree;

  final List<AvailableTime> _htemp = [];
  List<AvailableTime>? get htemp => _htemp;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    //notifyListeners();
  }

  ServiceManager() {
    _subscription?.cancel();
    _loading = false;
    //_listenToServices();
    _listenToEvents();
    _listenToAgenda();
  }

  String _search = '';

  String? _companyID = '';

  String? _categoryid = '';

  DateTime? _dateEvent = DateTime.now();

  set dateEvent(DateTime? value) {
    _dateEvent = value;
  }

  DateTime? get dateEvent => _dateEvent;

  String? get companyID => _companyID;

  set companyID(String? value) {
    _companyID = value;
    //  notifyListeners();
  }

  String? get categoryid => _categoryid;

  set categoryid(String? value) {
    _categoryid = value;
    // notifyListeners();
  }

  String get search => _search;

  set search(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> updatekeyword() async {
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

    final serviceCollection = FirebaseFirestore.instance.collection('services');
    // Obtém todos os documentos da coleção de serviços
    final querySnapshot = await serviceCollection.get();

    // Itera sobre cada documento
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final serviceName = data['name'] as String?;
      final description = data['description'] as String?;

      // Verifica se o nome do serviço existe
      if (serviceName != null) {
        // Gera as keywords
        List<String> keywords;
        if (description != null) {
          keywords = _generateKeywords(serviceName + ' ' + description);
        }
        keywords = _generateKeywords(serviceName);

        // Atualiza o documento com as keywords
        await doc.reference.update({'keywords': keywords});

        print('Documento ${doc.id} atualizado com sucesso!');
      } else {
        print('Nome do serviço não encontrado no documento ${doc.id}');
      }
    }

    print('Atualização concluída!');
  }

  List<Service> get filteredServices {
    final List<Service> filteredServices = [];
    loading = true;
    _listenToServices();
    if (search.isEmpty) {
      filteredServices.addAll(services);
    } else {
      filteredServices.addAll(services.where((p) => removeDiacritics(p.name!)
          .toLowerCase()
          .contains(removeDiacritics(search).toLowerCase())));
    }
    loading = false;
    return filteredServices;
  }

  List<Service> get filteredServicescpct {
    final List<Service> filteredServicescpct = [];
    loading = true;
    _listenToServices();
    if (companyID == "0" && categoryid == "0") {
      filteredServicescpct.addAll(filteredServices
          .where((p) => p.type == false)
          .where((p) => p.companyID != null));
    } else if (companyID == "0" && categoryid != "0") {
      filteredServicescpct.addAll(filteredServices
          .where((p) => p.categoryid!.contains(categoryid!))
          .where((p) => p.type == false));
    } else if (companyID != "0" && categoryid == "0") {
      filteredServicescpct.addAll(filteredServices
          .where((p) => p.companyID!.contains(companyID!))
          .where((p) => p.type == false));
    } else {
      filteredServicescpct.addAll(filteredServices
          .where((p) => p.categoryid!.contains(categoryid!))
          .where((p) => p.companyID!.contains(companyID!))
          .where((p) => p.type == false));
    }
    filteredServicescpct.sort(
      (a, b) => a.name!.toUpperCase().compareTo(b.name!.toUpperCase()),
    );
    loading = false;
    return filteredServicescpct;
  }

  List<Service> get filteredServicesvet {
    final List<Service> filteredServicesvet = [];
    loading = true;
    if (companyID == "0") {
      filteredServicesvet.addAll(filteredServices.where((p) => p.type == true));
    } else if (categoryid == "0") {
      filteredServicesvet.addAll(filteredServices
          .where((p) => p.companyID!.contains(companyID!))
          .where((p) => p.type == true));
    } else {
      filteredServicesvet.addAll(filteredServices
          .where((p) => p.companyID!.contains(companyID!))
          .where((p) => p.categoryid!.contains(categoryid!))
          .where((p) => p.type == true));
    }
    filteredServicesvet.sort(
      (a, b) => a.name!.toUpperCase().compareTo(b.name!.toUpperCase()),
    );
    loading = false;
    return filteredServicesvet;
  }

  List<Service> get filteredServicescompany {
    final List<Service> filteredServicescompany = [];
    loading = true;

    filteredServicescompany.addAll(
        filteredServices.where((p) => p.companyID!.contains(companyID!)));
    loading = false;
    return filteredServicescompany;
  }

  void _listenToEvents() {
    _subscription = firestore
        .collection('events')
        .orderBy('event_date')
        .orderBy('serviceid')
        .snapshots()
        .listen((event) {
      events.clear();
      for (final doc in event.docs) {
        events.add(AppEvent.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  void _listenToAgenda() {
    _subscription = firestore
        .collection('available_times')
        //.where('companyID', isEqualTo: companyID)
        .snapshots()
        .listen((h) {
      htemp?.clear();
      for (final doc in h.docs) {
        htemp?.add(AvailableTime.fromDocument(doc));
      }
      // notifyListeners();
    });
  }

  List<AppEvent> get filteredEvent {
    loading = true;
    _listenToEvents();
    List<AppEvent> filteredEvent = [];

    filteredEvent.addAll(events.where((e) =>
        e.event_date!.day == dateEvent!.day &&
        e.event_date!.month == dateEvent!.month &&
        e.event_date!.year == dateEvent!.year &&
        e.companyID == companyID));
    loading = false;
    return filteredEvent;
  }

  List<String> get ghfree {
    loading = true;
    _listenToAgenda();
    //List<String> ghfree = [];
    hfree.clear();
    List<AvailableTime> hours2 = [];
    hours2.clear();
    hours2.addAll(htemp!.where((e) =>
        e.dateSchedule!.day == dateEvent!.day &&
        e.dateSchedule!.month == dateEvent!.month &&
        e.dateSchedule!.year == dateEvent!.year &&
        e.companyID == companyID));
    final hournow = DateTime.now().hour.toString() +
        ':' +
        DateTime.now().minute.toStringAsPrecision(2);

    for (final hd in hours2) {
      for (final h in hd.timeOfs!) {
        if (h.available_slots! > 0) {
          hfree.add(h.scheduleT ?? '');
        }
      }
    }

    hfree.sort();
    for (int i = 0; i < hfree.length; i++) {
      List<AppEvent> ev = [];

      ev.addAll(filteredEvent.where((e) =>
          (formatter.format(e.event_date!.hour) +
              ':' +
              formatter.format(e.event_date!.minute)) ==
          hfree[i]));
      int qts = 0;
      if (service != null) qts = service!.qtdatd!.toInt();

      if (ev.length > 0 && ev.length >= qts) {
        for (final h in hours2) {
          for (final h2 in h.timeOfs!) {
            for (final evt in ev) {
              if (h2.scheduleT ==
                  (evt.event_date!.hour.toString() +
                      ":" +
                      evt.event_date!.minute.toString()))
                //if (h2.available_slots! <= ev.length) {
                hfree.remove(h2.scheduleT);
              //}
            }
          }
        }
      }
      if (dateEvent!.day == DateTime.now().day &&
          dateEvent!.month == DateTime.now().month &&
          dateEvent!.year == DateTime.now().year) {
        String nhournow = hournow.replaceAll(':', '');
        nhournow = nhournow.replaceAll('.', '');

        hfree.removeWhere((element) =>
            num.parse(element.replaceAll(':', '')) < num.parse(nhournow) + 30);
      }
    }

    // for (int i = 0; i < hfree.length; i++) {
    //   ghfree.add(hfree[i]);
    // }
    // ghfree = hfree;
    htemp?.clear();
    var hhfree = hfree;
    if (hfree.isEmpty) {
      hhfree = hoursfree;
    }
    loading = false;
    return hhfree;
  }

  List<String> get hoursfree {
    final List<String> hoursfree = [];
    loading = true;
    List<String> hours2 = [];
    hours2.clear();
    final hournow = DateTime.now().hour.toString() +
        ':' +
        DateTime.now().minute.toStringAsPrecision(2);

    for (int i = 0; i < service!.hours!.length; i++) {
      hours2.add(service!.hours![i]);
    }

    hours2.sort();
    for (int i = 0; i < hours2.length; i++) {
      List<AppEvent> ev = [];

      ev.addAll(filteredEvent.where((e) =>
          (formatter.format(e.event_date!.hour) +
              ':' +
              formatter.format(e.event_date!.minute)) ==
          hours2[i]));
      int qts = service!.qtdatd!.toInt();

      if (ev.length >= qts) {
        hours2.remove(hours2[i]);
      }
      if (dateEvent!.day == DateTime.now().day &&
          dateEvent!.month == DateTime.now().month &&
          dateEvent!.year == DateTime.now().year) {
        String nhournow = hournow.replaceAll(':', '');
        nhournow = nhournow.replaceAll('.', '');

        hours2.removeWhere((element) =>
            num.parse(element.replaceAll(':', '')) < num.parse(nhournow) + 30);
      }
    }

    for (int i = 0; i < hours2.length; i++) {
      hoursfree.add(hours2[i]);
    }
    loading = false;
    return hoursfree;
  }

  void _listenToServices() async {
    if (companyID != null && companyID != '0' && companyID != '') {
      _subscription = await firestore
          .collection('services')
          .where('deleted', isEqualTo: false)
          .where('companyID', isEqualTo: companyID)
          .snapshots()
          .listen((ev) {
        services.clear();
        for (final doc in ev.docs) {
          services.add(Service.fromDocument(doc));
        }
      });
    } else if (companyID == '0') {
      _subscription = await firestore
          .collection('services')
          .where('deleted', isEqualTo: false)
          .snapshots()
          .listen((ev) {
        services.clear();
        for (final doc in ev.docs) {
          services.add(Service.fromDocument(doc));
        }
      });
    }

    notifyListeners();
  }

  Service findServiceByID(String? id) {
    if (services.isEmpty) _listenToServices();
    return services.firstWhere((p) => p.id == id);
  }

  void delete(Service service) {
    service.delete();
    services.removeWhere((p) => p.id == service.id);
    notifyListeners();
  }

  void update(Service service) {
    services.removeWhere((p) => p.id == service.id);
    if (service.companyID == null) service.companyID = this.user!.companyID;

    services.add(service);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  void updateUser(Userapp? user) {
    this.user = user;
  }

  void updateDataEvent(DateTime? dataEvent) {
    this.dateEvent = dataEvent;
  }

  void updateService(Service service) {
    this.service = service;
  }

  void setCompanid(String value) {
    companyID = value;
  }
}
