import 'dart:convert';

class Booking {
  final String id;
  final String userID; // Usuário que fez o agendamento
  final String serviceID; // Serviço escolhido
  final DateTime time; // Horário reservado
  Booking({
    required this.id,
    required this.userID,
    required this.serviceID,
    required this.time,
  });

  Booking copyWith({
    String? id,
    String? userID,
    String? serviceID,
    String? timeID,
  }) {
    return Booking(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      serviceID: serviceID ?? this.serviceID,
      time: time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userID': userID,
      'serviceID': serviceID,
      'time': time,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      userID: map['userID'] ?? '',
      serviceID: map['serviceID'] ?? '',
      time: map['time'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Booking.fromJson(String source) =>
      Booking.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Booking(id: $id, userID: $userID, serviceID: $serviceID, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Booking &&
        other.id == id &&
        other.userID == userID &&
        other.serviceID == serviceID &&
        other.time == time;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userID.hashCode ^ serviceID.hashCode ^ time.hashCode;
  }
}
