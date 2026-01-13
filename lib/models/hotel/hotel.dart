// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../user/userapp.dart';

class Hotel extends ChangeNotifier {
  String? id;
  DateTime? ini_date;
  DateTime? end_date;

  String? categoryID;
  String? companyID;
  String? userID;
  Userapp? userapp;
  String? accid;
  Colors? backgroud;
  num? price;

  Hotel({
    this.id,
    this.ini_date,
    this.end_date,
    this.categoryID,
    this.companyID,
    this.userID,
    this.userapp,
    this.accid,
    this.backgroud,
    this.price,
  });

  Hotel copyWith({
    String? id,
    DateTime? ini_date,
    DateTime? end_date,
    String? categoryID,
    String? companyID,
    String? userID,
    Userapp? userapp,
    String? accid,
    Colors? backgroud,
    num? price,
  }) {
    return Hotel(
      id: id ?? this.id,
      ini_date: ini_date ?? this.ini_date,
      end_date: end_date ?? this.end_date,
      categoryID: categoryID ?? this.categoryID,
      companyID: companyID ?? this.companyID,
      userID: userID ?? this.userID,
      userapp: userapp ?? this.userapp,
      accid: accid ?? this.accid,
      backgroud: backgroud ?? this.backgroud,
      price: price ?? this.price,
    );
  }

  String get formattedId => '#${id!.padLeft(6, '0')}';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ini_date': ini_date?.millisecondsSinceEpoch,
      'end_date': end_date?.millisecondsSinceEpoch,
      'categoryID': categoryID,
      'companyID': companyID,
      'userID': userID,
      'userapp': userapp?.toMap(),
      'accid': accid,
      'backgroud': backgroud,
      'price': price,
    };
  }

  factory Hotel.fromDS(String id, Map<String, dynamic>? map) {
    return Hotel(
        id: id,
        ini_date: (map!['ini_date'] as Timestamp).toDate(),
        end_date: (map['end_date'] as Timestamp).toDate(),
        categoryID: map['categoryID'],
        companyID: map['companyID'],
        userID: map['userID'],
        accid: map['accid'],
        userapp: map['userapp'],
        backgroud: map['backgroud'],
        price: map['price']);
  }

  String toJson() => json.encode(toMap());

  Hotel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    ini_date = (doc.get('ini_date') as Timestamp).toDate();
    end_date = (doc.get('end_date') as Timestamp).toDate();
    categoryID = doc.get('categoryID') as String;
    companyID = doc.get('companyID') as String;
    userID = doc.get('userID') as String;
    accid = doc.get('accid') as String;
    price = doc.get('price') as num;
  }

  @override
  String toString() {
    return 'Hotel(id: $id, ini_date: $ini_date, end_date: $end_date, categoryID: $categoryID, companyID: $companyID, userID: $userID, userapp: $userapp, accid: $accid, backgroud: $backgroud, price: $price)';
  }

  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      id: map['id'] != null ? map['id'] as String : null,
      ini_date: map['ini_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['ini_date'] as int)
          : null,
      end_date: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      categoryID:
          map['categoryID'] != null ? map['categoryID'] as String : null,
      companyID: map['companyID'] != null ? map['companyID'] as String : null,
      userID: map['userID'] != null ? map['userID'] as String : null,
      userapp: map['userapp'] != null
          ? Userapp.fromMap(map['userapp'] as Map<String, dynamic>)
          : null,
      accid: map['accid'] != null ? map['accid'] as String : null,
      backgroud: map['backgroud'],
      price: map['price'] != null ? map['price'] as num : null,
    );
  }

  factory Hotel.fromJson(String source) =>
      Hotel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Hotel &&
        other.id == id &&
        other.ini_date == ini_date &&
        other.end_date == end_date &&
        other.categoryID == categoryID &&
        other.companyID == companyID &&
        other.userID == userID &&
        other.userapp == userapp &&
        other.accid == accid &&
        other.backgroud == backgroud &&
        other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ini_date.hashCode ^
        end_date.hashCode ^
        categoryID.hashCode ^
        companyID.hashCode ^
        userID.hashCode ^
        userapp.hashCode ^
        accid.hashCode ^
        backgroud.hashCode ^
        price.hashCode;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference get firestoreRef => firestore.collection('hotel').doc(id);
}
