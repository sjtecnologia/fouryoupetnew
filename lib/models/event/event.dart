import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:fouryoupet/models/user/userapp.dart';

enum Status { active, canceled, finalizado }

class AppEvent extends ChangeNotifier {
  String? title;
  String? id;
  String? description;
  DateTime? event_date;
  String? categoryID;
  String? companyID;
  bool? type;
  String? userID;
  Userapp? userapp;
  String? serviceid;
  Colors? backgroud;
  num? price;
  Status? status;
  double? discount;
  String? couponCode;

  AppEvent({
    this.title,
    this.id,
    this.description,
    this.event_date,
    this.categoryID,
    this.companyID,
    this.type,
    this.userID,
    this.userapp,
    this.serviceid,
    this.backgroud,
    this.price,
    this.status,
    this.discount,
    this.couponCode,
  });

  AppEvent copyWith({
    String? title,
    String? id,
    String? description,
    DateTime? event_date,
    String? categoryID,
    String? companyID,
    bool? type,
    String? userID,
    Userapp? userapp,
    String? serviceid,
    Colors? backgroud,
    num? price,
    Status? status,
    double? discount,
    String? couponCode,
  }) {
    return AppEvent(
        title: title ?? this.title,
        id: id ?? this.id,
        description: description ?? this.description,
        event_date: event_date ?? this.event_date,
        categoryID: categoryID ?? this.categoryID,
        companyID: companyID ?? this.companyID,
        type: type ?? this.type,
        userID: userID ?? this.userID,
        userapp: userapp ?? this.userapp,
        serviceid: serviceid ?? this.serviceid,
        backgroud: backgroud ?? this.backgroud,
        price: price ?? this.price,
        status: status ?? this.status,
        discount: discount ?? this.discount,
        couponCode: couponCode ?? this.couponCode);
  }

  String get formattedId => '#${id!.padLeft(6, '0')}';

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'id': id,
      'description': description,
      'event_date': event_date,
      'categoryID': categoryID,
      'companyID': companyID,
      'type': type,
      'userID': userID,
      'userapp': userapp,
      'serviceid': serviceid,
      'backgroud': backgroud,
      'price': price,
      'status': status,
      'discount': discount,
      'couponCode': couponCode,
    };
  }

  factory AppEvent.fromDS(String id, Map<String, dynamic>? map) {
    return AppEvent(
        title: map?['title'],
        id: id,
        description: map?['description'],
        event_date: (map?['event_date'] as Timestamp).toDate(),
        categoryID: map?['categoryID'],
        companyID: map?['companyID'],
        type: map?['type'],
        userID: map?['userID'],
        serviceid: map?['serviceid'],
        userapp: map?['userapp'],
        backgroud: map?['backgroud'],
        price: map?['price'],
        status: map?['status'],
        discount: map?['discount'],
        couponCode: map?['couponCode']);
  }

  String toJson() => json.encode(toMap());

  AppEvent.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    title = doc.get('title') as String;
    description = doc.get('description') as String;
    event_date = (doc.get('event_date') as Timestamp).toDate();

    categoryID = doc.get('categoryID') as String;
    companyID = doc.get('companyID') as String;
    type = doc.get('type') as bool;
    userID = doc.get('userID') as String;
    serviceid = doc.get('serviceid') as String;
    price = doc.get('price') as num;
    status = Status.values[doc.get('status') as int];
    Map<String, dynamic> dataMap = doc.data() as Map<String, dynamic>;
    if (dataMap.containsKey('discount')) {
      discount = doc.get('discount') != null
          ? (doc.get('discount') as num).toDouble()
          : null;
    }
    if (dataMap.containsKey('couponCode')) {
      couponCode = doc.get('couponCode') as String?;
    }
    notifyListeners();
  }

  @override
  String toString() {
    return 'AppEvent(title: $title, id: $id, description: $description, event_date: $event_date, categoryID: $categoryID, companyID: $companyID, type: $type, userID: $userID, userapp: $userapp, serviceid: $serviceid, backgroud: $backgroud, price: $price, status: $status, discount: $discount, couponCode: $couponCode)';
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference get firestoreRef => firestore.collection('events').doc(id);

  CollectionReference get groupReference => firestoreRef.collection('messeges');

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    id = groupId;
    groupReference.add(chatMessageData);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppEvent &&
        other.title == title &&
        other.id == id &&
        other.description == description &&
        other.event_date == event_date &&
        other.categoryID == categoryID &&
        other.companyID == companyID &&
        other.type == type &&
        other.userID == userID &&
        other.userapp == userapp &&
        other.serviceid == serviceid &&
        other.backgroud == backgroud &&
        other.price == price &&
        other.status == status &&
        other.discount == discount &&
        other.couponCode == couponCode;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        id.hashCode ^
        description.hashCode ^
        event_date.hashCode ^
        categoryID.hashCode ^
        companyID.hashCode ^
        type.hashCode ^
        userID.hashCode ^
        userapp.hashCode ^
        serviceid.hashCode ^
        backgroud.hashCode ^
        price.hashCode ^
        status.hashCode ^
        discount.hashCode ^
        couponCode.hashCode;
  }

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    return AppEvent(
      title: map['title'],
      id: map['id'],
      description: map['description'] ?? '',
      event_date: DateTime.fromMillisecondsSinceEpoch(map['event_date']),
      categoryID: map['categoryID'],
      companyID: map['companyID'],
      type: map['type'],
      userID: map['userID'],
      userapp: Userapp.fromMap(map['userapp']),
      serviceid: map['serviceid'],
      backgroud: map['backgroud'],
      price: map['price'],
      status: map['status'],
      discount:
          map['discount'] != null ? (map['discount'] as num).toDouble() : null,
      couponCode: map['couponCode'],
    );
  }

  Future<void> cancel() async {
    try {
      status = Status.canceled;
      firestoreRef.update({'status': status!.index});
    } catch (e) {
      debugPrint('Erro ao cancelar');
      return Future.error('Falha ao cancelar');
    }
  }

  Future<void> finaliza() async {
    try {
      status = Status.finalizado;
      firestoreRef.update({'status': status!.index});
    } catch (e) {
      debugPrint('Erro ao finalizar');
      return Future.error('Falha ao finalizar');
    }
  }

  String get statusText => getStatusText(status);
  static String getStatusText(Status? status) {
    switch (status) {
      case Status.canceled:
        return 'Cancelado';
      case Status.active:
        return 'Ativo';
      case Status.finalizado:
        return 'Finalizado';
      default:
        return '';
    }
  }

  factory AppEvent.fromJson(String source) =>
      AppEvent.fromMap(json.decode(source));
}
