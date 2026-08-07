class ScheduleTimes {
  ScheduleTimes({
    this.scheduleT,
    this.available_slots,
  }) {}

  String? scheduleT;
  int? available_slots;

  ScheduleTimes.fromMap(Map<String, dynamic> map) {
    final dynamic rawSchedule = map['scheduleT'] ?? map['schedule'];
    scheduleT = rawSchedule?.toString();

    final dynamic rawSlots = map['available_slots'] ?? map['availableSlots'];
    if (rawSlots is int) {
      available_slots = rawSlots;
    } else if (rawSlots is double) {
      available_slots = rawSlots.toInt();
    } else if (rawSlots is String) {
      available_slots = int.tryParse(rawSlots.trim());
    } else {
      available_slots = null;
    }
  }

  ScheduleTimes clone() {
    return ScheduleTimes(
      scheduleT: scheduleT,
      available_slots: available_slots,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scheduleT': scheduleT,
      'available_slots': available_slots,
    };
  }

  @override
  String toString() {
    return 'ScheduleTimes{scheduleT: $scheduleT, available_slots: $available_slots}';
  }
}
