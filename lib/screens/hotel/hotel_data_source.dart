import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fouryoupet/models/hotel/hotel.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/admin/admin_users_manager.dart';

class HotelDataSource extends CalendarDataSource {
  HotelDataSource(List<Hotel> appointments) {
    this.appointments = appointments;
  }

  // Random random = new Random();
  // int idx = 0;

  Hotel? getHotel(int index) => appointments![index] as Hotel?;
  AdminUsersManager? username;

  @override
  DateTime getStartTime(int index) => getHotel(index)!.ini_date!;

  @override
  DateTime getEndTime(int index) => getHotel(index)!.end_date!;

  @override
  String getSubject(int index) => 'Hostelzinho';

  @override
  String? getNotes(int index) => 'Hospedagem';

  @override
  bool isAllDay(int index) => false;

  @override
  Color getColor(int index) {
    final Color _color =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];
    return _color;
  }
}
