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

  StreamSubscription? _eventsSubscription;
  StreamSubscription? _agendaSubscription;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    //notifyListeners();
  }

  ServiceManager() {
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

        debugPrint('Documento ${doc.id} atualizado com sucesso!');
      } else {
        debugPrint('Nome do serviço não encontrado no documento ${doc.id}');
      }
    }

    debugPrint('Atualização concluída!');
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
    _eventsSubscription = firestore
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
    _agendaSubscription =
        firestore.collection('available_times').snapshots().listen((h) {
      htemp?.clear();
      for (final doc in h.docs) {
        htemp?.add(AvailableTime.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  List<AppEvent> get filteredEvent {
    loading = true;
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
    // Caminho 1: verificar se há agenda na tabela available_times
    // para este fornecedor e data selecionada
    debugPrint(
        '[ghfree] companyID=$companyID | dateEvent=$dateEvent | htemp.length=${htemp?.length}');
    final agendaSlots = htemp!
        .where((e) =>
            e.dateSchedule!.day == dateEvent!.day &&
            e.dateSchedule!.month == dateEvent!.month &&
            e.dateSchedule!.year == dateEvent!.year &&
            e.companyID == companyID)
        .toList();

    if (agendaSlots.isNotEmpty) {
      hfree.clear();
      for (final slot in agendaSlots) {
        for (final h in slot.timeOfs!) {
          if ((h.available_slots ?? 0) > 0) {
            hfree.add(h.scheduleT ?? '');
          }
        }
      }
      hfree.sort();

      // Remove slots já lotados (confirma contra a coleção events)
      final booked = filteredEvent;
      final qtd = service?.qtdatd ?? 1;
      hfree.removeWhere((hour) {
        final count = booked
            .where((e) =>
                '${formatter.format(e.event_date!.hour)}:${formatter.format(e.event_date!.minute)}' ==
                hour)
            .length;
        return count >= qtd;
      });

      _removePastHours(hfree);
      debugPrint(
          '[ghfree] Caminho 1 (available_times): ${hfree.length} horários → $hfree');
      return hfree;
    }

    // Caminho 2: sem agenda na tabela, monta a partir da config do serviço
    debugPrint('[ghfree] Sem agenda → Caminho 2 (config serviço)');
    return hoursfree;
  }

  /// Remove horários passados (+ 30 min de antecedência) quando a data
  /// selecionada for hoje.
  void _removePastHours(List<String> hours) {
    if (dateEvent!.day != DateTime.now().day ||
        dateEvent!.month != DateTime.now().month ||
        dateEvent!.year != DateTime.now().year) return;
    final nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute + 30;
    hours.removeWhere((hour) {
      final parts = hour.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      return (h * 60 + m) < nowMinutes;
    });
  }

  /// Caminho 2: monta horários a partir da configuração do serviço
  /// (campos hinit, hend, hminute da tabela services), filtra lotados e passados.
  List<String> get hoursfree {
    if (service == null) {
      debugPrint('[hoursfree] service é null, retornando []');
      return [];
    }
    debugPrint(
        '[hoursfree] service=${service!.name} | hours=${service!.hours} | hinit=${service!.hinit} | hend=${service!.hend} | hminute=${service!.hminute}');

    List<String> hours2 = [];

    // Usa o array 'hours' já salvo no serviço, ou gera a partir de hinit/hend/hminute
    if (service!.hours != null && service!.hours!.isNotEmpty) {
      hours2 = List<String>.from(service!.hours!);
    } else if ((service!.hinit ?? 0) > 0 &&
        (service!.hend ?? 0) > 0 &&
        (service!.hminute ?? 0) > 0) {
      for (int h = service!.hinit!; h <= service!.hend!; h++) {
        for (int m = 0; m < 60; m += service!.hminute!) {
          hours2.add('${formatter.format(h)}:${formatter.format(m)}');
        }
      }
    }

    if (hours2.isEmpty) return [];

    hours2.sort();

    // Remove slots já lotados
    final booked = filteredEvent;
    final qtd = service!.qtdatd ?? 1;
    hours2.removeWhere((hour) {
      final count = booked
          .where((e) =>
              '${formatter.format(e.event_date!.hour)}:${formatter.format(e.event_date!.minute)}' ==
              hour)
          .length;
      return count >= qtd;
    });

    // Remove horários passados se for hoje
    _removePastHours(hours2);

    return hours2;
  }

  StreamSubscription? _servicesSubscription;

  void _listenToServices() {
    if (companyID != null && companyID != '0' && companyID != '') {
      _servicesSubscription = firestore
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
      _servicesSubscription = firestore
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
    _eventsSubscription?.cancel();
    _agendaSubscription?.cancel();
    _servicesSubscription?.cancel();
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
