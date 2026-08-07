import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';
import 'package:fouryoupet/models/hotel/hotel.dart';

import 'package:fouryoupet/models/user/userapp.dart';
import 'package:intl/intl.dart';
import 'package:fouryoupet/common/extensions/datetime_extension.dart';

class AccommodationManager extends ChangeNotifier {
  List<Accommodation> accommodations = [];
  NumberFormat formatter = NumberFormat("00");

  Userapp? user;

  Accommodation? accommodation;

  final List<Hotel> _hotel = [];
  List<Hotel> get hotel => _hotel;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  AccommodationManager() {
    _subscription?.cancel();
    //_listenToAccommodation();
    _listenToHotel();
  }

  Future<void> fetchAccommodations() async {
    if (_companyID == null || _companyID!.isEmpty) {
      return;
    }

    try {
      Query<Map<String, dynamic>> query = firestore
          .collection('accommodation')
          .where('deleted', isEqualTo: false);

      if (_companyID != '0') {
        query = query.where('companyID', isEqualTo: _companyID);
      }

      final querySnapshot = await query.get();

      accommodations.clear();
      for (var doc in querySnapshot.docs) {
        accommodations.add(Accommodation.fromDocument(doc));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar accommodations: $e');
    }
  }

  String _search = '';

  String? _companyID = '';

  String? _categoryid = '';

  DateTime? _dateIniHotel = DateTime.now();

  set dateIniHotel(DateTime? value) {
    _dateIniHotel = value;
  }

  DateTime? get dateIniHotel => _dateIniHotel;

  DateTime? _dateEndHotel = DateTime.now();

  set dateEndHotel(DateTime? value) {
    _dateEndHotel = value;
  }

  DateTime? get dateEndHotel => _dateEndHotel;

  String? get companyID => _companyID;

  set companyID(String? value) {
    _companyID = value;
    //  notifyListeners();
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

    final accommodationCollection =
        FirebaseFirestore.instance.collection('accommodation');
    // Obtém todos os documentos da coleção de accommodation
    final querySnapshot = await accommodationCollection.get();

    // Itera sobre cada documento
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final accommodationName = data['name'] as String?;
      final description = data['description'] as String?;

      // Verifica se o nome do accommodation existe
      if (accommodationName != null) {
        // Gera as keywords
        List<String> keywords;
        if (description != null) {
          keywords = _generateKeywords(accommodationName + ' ' + description);
        } else
          keywords = _generateKeywords(accommodationName);

        // Atualiza o documento com as keywords
        await doc.reference.update({'keywords': keywords});

        debugPrint('Documento ${doc.id} atualizado com sucesso!');
      } else {
        debugPrint(
            'Nome do accommodation não encontrado no documento ${doc.id}');
      }
    }

    debugPrint('Atualização concluída!');
  }

  String? get categoryid => _categoryid;

  set categoryid(String? value) {
    _categoryid = value;
    _listenToHotel();
  }

  String get search => _search;

  set search(String value) {
    _search = value;
    notifyListeners();
  }

  List<Accommodation> get filteredAccommodation {
    final List<Accommodation> filteredAccommodation = [];

    if (search.isEmpty) {
      filteredAccommodation.addAll(accommodations);
    } else {
      filteredAccommodation.addAll(accommodations
          .where((p) => p.name!.toLowerCase().contains(search.toLowerCase())));
    }
    return filteredAccommodation;
  }

  List<Accommodation> get filteredAccs {
    final List<Accommodation> filteredAccs = [];

    if (companyID == "0" && categoryid == "0") {
      filteredAccs.addAll(filteredAccommodation);
    } else if (companyID == "0" && categoryid != "0") {
      filteredAccs.addAll(filteredAccommodation
          .where((p) => p.categoryid!.contains(categoryid!)));
    } else if (companyID != "0" && categoryid == "0") {
      filteredAccs.addAll(filteredAccommodation
          .where((p) => p.companyID!.contains(companyID!)));
    } else {
      filteredAccs.addAll(filteredAccommodation
          .where((p) => p.categoryid!.contains(categoryid!))
          .where((p) => p.companyID!.contains(companyID!)));
    }

    return filteredAccs;
  }

  List<Accommodation> get filteredAcccompany {
    final List<Accommodation> filteredAcccompany = [];
    if (companyID == '0' && categoryid == '0') {
      filteredAcccompany.addAll(accommodations);
    } else if (companyID == '0' && categoryid != '0') {
      filteredAcccompany.addAll(
          accommodations.where((p) => p.categoryid!.contains(categoryid!)));
    } else if (categoryid != '0') {
      filteredAcccompany.addAll(accommodations.where((p) =>
          p.companyID!.contains(companyID!) &&
          p.categoryid!.contains(categoryid!)));
    } else {
      filteredAcccompany.addAll(
          accommodations.where((p) => p.companyID!.contains(companyID!)));
    }
    return filteredAcccompany;
  }

  List<Hotel> get filteredHotel {
    final List<Hotel> filteredHotel = [];
    filteredHotel.addAll(hotel);
    return filteredHotel;
  }

  void _listenToHotel() {
    _subscription?.cancel();

    Query<Map<String, dynamic>> query = firestore.collection('hotel');

    if (accommodation?.id != null && accommodation!.id!.isNotEmpty) {
      query = query.where('accid', isEqualTo: accommodation!.id);
    }
    if (_categoryid != null && _categoryid!.isNotEmpty && _categoryid != '0') {
      query = query.where('categoryID', isEqualTo: _categoryid);
    }
    if (_companyID != null && _companyID!.isNotEmpty && _companyID != '0') {
      query = query.where('companyID', isEqualTo: _companyID);
    }

    _subscription = query.snapshots().listen((h) {
      hotel.clear();
      for (final doc in h.docs) {
        hotel.add(Hotel.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  List<Hotel> get filteredEvent {
    List<Hotel> filteredHotel = [];
    filteredHotel.addAll(hotel.where((e) =>
        e.ini_date == dateIniHotel &&
        e.companyID == companyID &&
        e.accid == accommodation!.id));
    return filteredHotel;
  }

  bool? exitevaga(DateTime? dateadd) {
    //_listenToHotel();
    bool? exitevaga = false;
    int? exist = 0;
    List<Hotel> filterexist = [];
    filterexist.addAll(hotel.where(
        (e) => e.companyID == companyID && e.accid == accommodation!.id));
    for (final ht in filterexist) {
      if (dateadd.isBetween(
          ht.ini_date as DateTime, ht.end_date as DateTime)!) {
        exist = exist! + 1;
      }
    }
    if (accommodation!.qtdatd! > exist!) exitevaga = true;
    return exitevaga;
  }

  List<Hotel> get filteredend {
    List<Hotel> filteredend = [];
    filteredend.addAll(hotel.where((e) =>
        e.ini_date!.isBefore(dateEndHotel!) &&
        e.end_date!.isAfter(dateEndHotel!) &&
        e.companyID == companyID &&
        e.accid == accommodation!.id));
    return filteredend;
  }

  Accommodation? findAccommodationByID(String? id) {
    try {
      return accommodations.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void delete(Accommodation accommodation) {
    accommodation.delete();
    accommodations.removeWhere((p) => p.id == accommodation.id);
    notifyListeners();
  }

  void update(Accommodation accommodation) {
    accommodations.removeWhere((p) => p.id == accommodation.id);
    if (accommodation.companyID == null)
      accommodation.companyID = this.user!.companyID;

    accommodations.add(accommodation);
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

  void updateDataIni(DateTime? dataini) {
    this.dateIniHotel = dataini;
  }

  void updateDataEnd(DateTime? dataend) {
    this.dateEndHotel = dataend;
  }

  void updateAcc(Accommodation accommodation) {
    this.accommodation = accommodation;
    _listenToHotel();
  }

  void setCompanid(String value) {
    companyID = value;
    _listenToHotel();
  }
}
