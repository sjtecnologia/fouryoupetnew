import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fouryoupet/models/event/event.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/admin/admin_users_manager.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<AppEvent> appointments) {
    this.appointments = appointments;
  }

  // Random random = new Random();
  // int idx = 0;

  AppEvent? getAppEvent(int index) => appointments![index] as AppEvent?;
  AdminUsersManager? username;

  @override
  DateTime getStartTime(int index) => getAppEvent(index)!.event_date!;

  @override
  DateTime getEndTime(int index) =>
      getAppEvent(index)!.event_date!.add(Duration(hours: 1));

  @override
  String getSubject(int index) => getAppEvent(index)!.title!;

  @override
  String? getNotes(int index) => getAppEvent(index)!.description;

  @override
  bool isAllDay(int index) => false;

  @override
  Color getColor(int index) {
    final Color _color = getAppEvent(index)!.statusText == 'Cancelado'
        ? Colors.red
        : Colors.primaries[Random().nextInt(Colors.primaries.length)];
    return _color;
  }
}
