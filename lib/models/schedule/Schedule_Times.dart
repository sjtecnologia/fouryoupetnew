class ScheduleTimes {
  ScheduleTimes({
    this.scheduleT,
    this.available_slots,
  }) {}

  String? scheduleT;
  int? available_slots;

  ScheduleTimes.fromMap(Map<String, dynamic> map) {
    scheduleT = map['scheduleT'] as String?;
    available_slots = map['available_slots'] as int?;
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
