// ignore_for_file: unused_local_variable, unused_element

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fouryoupet/models/schedule/schedule_manager.dart';

import 'package:fouryoupet/models/user/userapp.dart';
import 'package:provider/provider.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../common/custom_drawer/custom_drawer.dart';
import '../../models/page_manager.dart';
import '../../models/schedule/AvailableTime.dart';
import '../../models/schedule/Schedule_Times.dart';

List<int> listSlots = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20
]; // Valor padrão
List<int> intervalo = [
  5,
  10,
  15,
  20,
  25,
  30,
  35,
  40,
  45,
  50,
  55,
  60,
  65,
  70,
  75,
  80,
  85,
  90,
  95,
  100,
  105,
  115,
  120
];

DateTime agora = DateTime.now();

TimeOfDay timeini = TimeOfDay(hour: 5, minute: 00);
TimeOfDay timefim = TimeOfDay(hour: 23, minute: 59);
//.replacing(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

class AvailableTimeForm extends StatefulWidget {
  const AvailableTimeForm({Key? key, this.company}) : super(key: key);
  final String? company;
  @override
  _AvailableTimeFormState createState() => _AvailableTimeFormState();
}

List<AvailableTime> _availableHourstm = <AvailableTime>[];
int? qtd;

class _AvailableTimeFormState extends State<AvailableTimeForm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _availableHourstm = await context
              .read<ScheduleManager>()
              .loadTimes(widget.company!, selectedDate) ??
          <AvailableTime>[];
      qtd = _availableHourstm.length;
      await _availableHoursupdat(context);
    });
  }

  String getTimeString(int value) {
    final int hour = value ~/ 60;
    final int minutes = value % 60;
    return hour.toString().padLeft(2, '0') +
        ':' +
        minutes
            .toString()
            .padLeft(2, '0'); // TimeOfDay(hour: hour, minute: minutes);
  }

  Future<void> _availableHoursupdat(BuildContext context) async {
    _availableHourstm = await context
            .read<ScheduleManager>()
            .loadTimes(widget.company!, _selectedDay ?? selectedDate) ??
        <AvailableTime>[];
    qtd = _availableHourstm.length;
    String? id;
    if (qtd! > 0) {
      _availableHours = _availableHourstm.first.timeOfs!;
      id = _availableHourstm.first.id;
      if (_selectedDay != null) selectedDate = _selectedDay!;
    }

    AvailableTime _availableTime2 = AvailableTime(
        id: id,
        dateSchedule: selectedDate,
        companyID: widget.company,
        timeOfs: _availableHours,
        isBooked: false);

    if (_selectedDay != null) selectedDate = _selectedDay!;
    if (qtd == 0) {
      _availableHours.clear();
      var mtimeini = timeini.hour * 60 + timeini.minute;
      var mtimefim = timefim.hour * 60 + timefim.minute;

      for (var i = mtimeini; i <= mtimefim;) {
        _availableHours.add(ScheduleTimes(
            scheduleT: getTimeString(i), available_slots: selectedSlot));
        i = i + selectedIntervalo;
      }
    }
    _availableTime = (AvailableTime(
        id: id,
        dateSchedule: selectedDate,
        companyID: widget.company,
        timeOfs: _availableHours,
        isBooked: false));
    setState(() {});
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = new DateTime(agora.year, agora.month, agora.day, 0, 0);
  DateTime? _selectedDay;
  DateTime selectedDate = DateTime(agora.year, agora.month, agora.day, 0, 0);
  TimeOfDay selectedTime = TimeOfDay.now();

  AvailableTime _availableTime = AvailableTime();

  List<ScheduleTimes> _availableHours = [];

  int selectedSlot = listSlots.first;
  int selectedIntervalo = intervalo[5];

  Future<void> _selectTimeINI(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeini,
    );
    if (picked != null && picked != timeini)
      setState(() {
        timeini = picked;
        context.read<ScheduleManager>().delete(_availableTime);
        _availableHoursupdat(context);
      });
  }

  Future<void> _selectTimeFIM(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timefim,
    );
    if (picked != null && picked != timefim)
      setState(() {
        timefim = picked;
        context.read<ScheduleManager>().delete(_availableTime);
        _availableHoursupdat(context);
      });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    Userapp userapp = new Userapp();

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 111, 0),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Horários da Agenda',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              // Se necessário, feche telas abertas
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
              //Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<ScheduleManager>(builder: (_, scheduleManager, __) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TableCalendar(
                headerStyle: HeaderStyle(
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                  formatButtonVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                ),
                calendarStyle: CalendarStyle(
                    todayTextStyle: TextStyle(color: Colors.black),
                    defaultTextStyle: TextStyle(color: Colors.white),
                    todayDecoration: BoxDecoration(
                        color: Colors.black12, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    selectedTextStyle: TextStyle(color: primaryColor)),
                weekendDays: [DateTime.saturday, DateTime.sunday],
                locale: 'pt_BR',
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(2110),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = DateTime(selectedDay.year,
                          selectedDay.month, selectedDay.day, 0, 0);
                      _focusedDay = DateTime(focusedDay.year, focusedDay.month,
                          focusedDay.day, 0, 0);
                      _availableHoursupdat(context);
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    // Call `setState()` when updating calendar format
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = DateTime(
                      focusedDay.year, focusedDay.month, focusedDay.day, 0, 0);
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hora inicial',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _selectTimeINI(context);
                    },
                    icon: Icon(
                      Icons.punch_clock,
                      color: Colors.white,
                    ),
                    label: Text(
                      timeini.format(context),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // GestureDetector(
                  //   child: Text(
                  //     timeini.format(context),
                  //     style: TextStyle(
                  //         decoration: TextDecoration.underline,
                  //         color: Colors.white),
                  //   ),
                  //   onTap: () {
                  //     _selectTimeINI(context);
                  //   },
                  // ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Hora Final',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _selectTimeFIM(context);
                    },
                    icon: Icon(
                      Icons.punch_clock,
                      color: Colors.white,
                    ),
                    label: Text(
                      timefim.format(context),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Intervalo(min):',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<int>(
                    dropdownColor: Colors.black12,
                    style: TextStyle(color: Colors.white),
                    menuMaxHeight: 150,
                    value: selectedIntervalo,
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                    ),
                    elevation: 16,
                    onChanged: ((value) {
                      setState(() {
                        selectedIntervalo = value!;
                        context.read<ScheduleManager>().delete(_availableTime);
                        _availableHoursupdat(context);
                      });
                    }),
                    items: intervalo.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableTime.timeOfs?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      textColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      title:
                          Text('${_availableTime.timeOfs?[index].scheduleT}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Vagas:'),
                          SizedBox(width: 8),
                          DropdownButton<int>(
                            dropdownColor: Colors.black12,
                            style: TextStyle(color: Colors.white),
                            menuMaxHeight: 150,
                            value:
                                _availableTime.timeOfs?[index].available_slots,
                            icon: const Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                            ),
                            elevation: 16,
                            onChanged: ((value) {
                              setState(() {
                                _availableTime.timeOfs?[index].available_slots =
                                    value!;
                              });
                            }),
                            items: listSlots
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                ),
                onPressed: () async {
                  if (_availableHours.length > 0) {
                    try {
                      await context
                          .read<ScheduleManager>()
                          .saveAvailableTime(_availableTime);
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          message: "Agenda Gravada com Sucesso",
                        ),
                      );
                    } catch (e) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Erro ao gravar agenda",
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'SALVAR',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        }),
      ),
    );
  }
}
