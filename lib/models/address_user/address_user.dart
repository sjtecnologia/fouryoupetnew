import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/user/userapp.dart';

import '../address/address.dart';

class AddressUser extends ChangeNotifier {
  AddressUser.fromAddress(this._address, this._userapp) {
    userId = _userapp!.id;
    city = _address!.city;
    complement = _address!.complement;
    district = _address!.district;
    lat = _address!.lat;
    long = _address!.long;
    number = _address!.number;
    state = _address!.state;
    street = _address!.street;
    zipCode = _address!.zipCode;
  }

  AddressUser.fromDocument(DocumentSnapshot document) {
    id = document.id;
    userId = document.get('userid') as String?;
    city = document.get('city') ?? '';
    complement = document.get('complement') ?? '';
    district = document.get('district') ?? '';
    lat = document.get('lat') ?? 0.0;
    long = document.get('long') ?? 0.0;
    number = document.get('number') ?? '';
    state = document.get('state') ?? '';
    street = document.get('street') ?? '';
    zipCode = document.get('zipCode') ?? '';

    firestore.doc('users/$userId').get().then((doc) {
      userapp = Userapp.fromDocument(doc);
    });
  }

  AddressUser.fromMap(Map<String, dynamic> map) {
    userId = map['userId'] as String?;
    city = map['city'] ?? '';
    complement = map['complement'] ?? '';
    district = map['district'] ?? '';
    lat = map['lat'] ?? 0.0;
    long = map['long'] ?? 0.0;
    number = map['number'] ?? '';
    state = map['state'] ?? '';
    zipCode = map['zipCode'] ?? '';

    firestore.doc('users/$userId').get().then((doc) {
      userapp = Userapp.fromDocument(doc);
    });
  }

  Map<String, dynamic> toUserAddressMap() {
    return {
      'userId': userId,
      'city': city,
      'complement': complement,
      'district': district,
      'lat': lat,
      'long': long,
      'number': number,
      'state': state,
      'zipCode': zipCode
    };
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? id;
  String? userId;
  String? city;
  String? complement;
  String? district;
  double? lat;
  double? long;
  String? number;
  String? state;
  String? street;
  String? zipCode;

  Address? _address;
  Address? get address => _address;
  set address(Address? value) {
    _address = value;
    notifyListeners();
  }

  Userapp? _userapp;
  Userapp? get userapp => _userapp;
  set userapp(Userapp? value) {
    _userapp = value;
    notifyListeners();
  }
}
