import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/hotel/hotel.dart';
import 'package:fouryoupet/models/user/userapp.dart';

class HotelProvider extends ChangeNotifier {
  final List<Hotel> _hotel = [];
  final List<Hotel> _hotelcompany = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Hotel> get hotel => _hotel;
  List<Hotel> get hotelcompany => _hotelcompany;

  String? _companyID = '';

  String? get cpid => _companyID;

  void setCompanyID(String? id) => _companyID = id;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Hotel> get hotelsofSelectedDate => _hotel;

  //List<AppEvent> get eventsofUser => _events;

  void addHotel(Hotel hotel) {
    _hotel.add(hotel);

    notifyListeners();
  }

  Userapp? user;

  StreamSubscription? _subscription;

  void updateUser(Userapp? user, String? companyID) {
    this.user = user;
    hotel.clear();

    _subscription?.cancel();
    if (user != null) {
      _listenToHotel();
      if (companyID != null) _listenToHotelCompany(companyID);
    }
  }

  void _listenToHotel() {
    _subscription = firestore
        .collection('hotel')
        .where('userID', isEqualTo: user!.id)
        .orderBy('ini_date')
        .orderBy('end_date')
        .orderBy('accid')
        .snapshots()
        .listen((h) {
      hotel.clear();
      for (final doc in h.docs) {
        hotel.add(Hotel.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  void _listenToHotelCompany(String? companyID) {
    _subscription = firestore
        .collection('hotel')
        .where('companyID', isEqualTo: companyID)
        .orderBy('ini_date')
        .orderBy('end_date')
        .orderBy('accid')
        .snapshots()
        .listen((h) {
      hotel.clear();
      for (final doc in h.docs) {
        hotel.add(Hotel.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}
