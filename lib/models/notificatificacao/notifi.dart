import 'package:cloud_firestore/cloud_firestore.dart';

class Notifi {
  String? notificationTitle;
  String? notificationBody;
  Timestamp? notificationDate;
  String? image;
  bool? lido = false;
  String? type;

  Notifi({
    this.notificationTitle,
    this.notificationBody,
    this.notificationDate,
    this.image,
    this.lido,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notificationTitle': notificationTitle,
      'notificationBody': notificationBody,
      'notificationDate': notificationDate,
      'image': image,
      'lido': lido,
      'type': type,
    };
  }

  factory Notifi.fromMap(Map<String, dynamic> map) {
    return Notifi(
      notificationTitle: map['notificationTitle'] != null
          ? map['notificationTitle'] as String
          : null,
      notificationBody: map['notificationBody'] != null
          ? map['notificationBody'] as String
          : null,
      notificationDate: map['notificationDate'] != null
          ? map['notificationDate'] as Timestamp
          : null,
      image: map['image'] != null ? map['image'] as String : null,
      lido: map['lido'] != null ? map['lido'] as bool : false,
      type: map['type'] != null ? map['type'] as String : null,
    );
  }
}
