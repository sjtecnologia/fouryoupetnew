import 'package:flutter/material.dart';

class TimeSlot extends ChangeNotifier {
  DateTime date;
  String time;
  String companyID;
  TimeSlot({
    required this.date,
    required this.time,
    required this.companyID,
  });
}
