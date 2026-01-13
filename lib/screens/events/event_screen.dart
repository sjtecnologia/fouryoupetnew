import 'package:flutter/material.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/admin/admin_users_manager.dart';
import 'package:fouryoupet/models/event/event.dart';
import 'package:fouryoupet/models/service/service_manager.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/events/add_ev.dart';
import 'package:fouryoupet/screens/events/data/services/event_provider.dart';

import 'package:fouryoupet/screens/events/event_data_source.dart';
import 'package:fouryoupet/screens/events/event_details.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../common/event/chat/chat_page_event.dart';
import '../../models/page_manager.dart';
import '../../models/user/userapp.dart';

class EventScreen extends StatefulWidget {
  const EventScreen(
      {Key? key, this.company, this.homeclic, required this.serviceid})
      : super(key: key);
  final String? company;
  final int? homeclic;
  final String serviceid;
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  CalendarController _calendarController = CalendarController();
  late Map<DateTime, List<AppEvent>> _groupedEvents;
  late DateTime today;
  DateTime? firstDate;
  DateTime? lastDate;

  _EventScreenState();

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    firstDate = DateTime.utc(today.year, today.month - 1, 1);
    lastDate = DateTime.utc(
      today.year,
      today.month + 1,
    ).subtract(Duration(days: 1));
  }

  _groupEvents(List<AppEvent> events) {
    _groupedEvents = {};

    events.forEach((event) {
      DateTime date = DateTime.utc(
          event.event_date!.year,
          event.event_date!.month,
          event.event_date!.day,
          event.event_date!.hour,
          event.event_date!.minute);
      if (_groupedEvents[date] == null) _groupedEvents[date] = [];
      _groupedEvents[date]!.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool typesrv = false;
    Userapp userapp = new Userapp();

    String title = 'Agendamentos Cuidados';
    Widget? drw;
    if (widget.homeclic == 3 || widget.homeclic == 8) {
      typesrv = true;
      title = 'Agendamentos Veterinário';
    }

    if (widget.homeclic! < 8) {
      drw = null;
    } else {
      drw = CustomDrawer();
    }

    return Scaffold(
      drawer: drw,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 111, 0),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(title,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer2<UserManager, EventProvider>(
          builder: (_, userManager, eventProvider, __) {
            if (userapp.id == null) {
              eventProvider.updateUser(userManager.userapp, typesrv, 1);
              if (eventProvider.user != null) userapp = eventProvider.user!;
            }
            //if (eventProvider.events.isNotEmpty) {
            final evenst = eventProvider.events;
            _groupEvents(evenst);

            return Card(
              margin: EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,
              child: SfCalendar(
                dataSource: EventDataSource(evenst),
                controller: _calendarController,
                todayHighlightColor: Colors.orange,
                showDatePickerButton: true,
                showNavigationArrow: true,
                showCurrentTimeIndicator: true,
                allowViewNavigation: true,

                view: CalendarView.month,
                appointmentTimeTextFormat: 'HH:mm',

                //onViewChanged: onViewChanged,
                monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator, //appointment,
                    showTrailingAndLeadingDates: true,
                    appointmentDisplayCount: 4,
                    agendaViewHeight: 240,
                    navigationDirection: MonthNavigationDirection.horizontal,
                    showAgenda: true,
                    agendaStyle: AgendaStyle(
                      appointmentTextStyle: TextStyle(fontSize: 18),
                    ),
                    numberOfWeeksInView: 6),
                timeSlotViewSettings: const TimeSlotViewSettings(
                  startHour: 00,
                  endHour: 24,
                  nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
                  timelineAppointmentHeight: 50,
                  timeRulerSize: 70,
                  timeIntervalWidth: 100,
                  minimumAppointmentDuration: Duration(minutes: 30),
                ),
                onTap: (details) {
                  if (details.appointments == null) return;
                  if (details.appointments!.length > 1 ||
                      details.appointments!.length == 0) return;

                  final AppEvent evnt = details.appointments!.first;
                  NumberFormat formatter = NumberFormat("00.00");

                  num inprice = num.parse(evnt.price!.toStringAsPrecision(2));
                  String stprice = formatter.format(inprice);
                  final username = context
                      .read<AdminUsersManager>()
                      .findUserappByID(evnt.userID.toString())
                      .name as String;

                  DateTime? dtaev = evnt.event_date;

                  String formattedDate =
                      DateFormat('dd/MM/yyyy HH:mm').format(dtaev!);

                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text('Detalhes'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(username),
                                  Text(evnt.title as String),
                                  Text(evnt.description as String),
                                  Text('Valor: ' + stprice),
                                  Text(formattedDate),
                                  Text(
                                    evnt.statusText,
                                    style: TextStyle(
                                      color: evnt.status == 'Cancelado'
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              if (eventProvider
                                          .events[eventProvider.events
                                              .indexOf(evnt)]
                                          .statusText !=
                                      'Cancelado' &&
                                  eventProvider
                                          .events[eventProvider.events
                                              .indexOf(evnt)]
                                          .statusText !=
                                      'Finalizado')
                                TextButton(
                                  onPressed: () {
                                    eventProvider.events[
                                            eventProvider.events.indexOf(evnt)]
                                        .finaliza();
                                    Navigator.pop(context, 'Finalizar');
                                  },
                                  child: const Text('Finalizar'),
                                ),
                              if (eventProvider
                                          .events[eventProvider.events
                                              .indexOf(evnt)]
                                          .statusText !=
                                      'Cancelado' &&
                                  eventProvider
                                          .events[eventProvider.events
                                              .indexOf(evnt)]
                                          .statusText !=
                                      'Finalizado')
                                TextButton(
                                  onPressed: () {
                                    eventProvider.events[
                                            eventProvider.events.indexOf(evnt)]
                                        .cancel();
                                    Navigator.pop(context, 'Cancelar');
                                  },
                                  child: const Text('Cancelar'),
                                ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  List<String>? tk = [];
                                  if (context
                                      .read<UserManager>()
                                      .adminEnabled) {
                                    if (context
                                            .read<UserManager>()
                                            .userapp!
                                            .companyID ==
                                        eventProvider
                                            .events[eventProvider.events
                                                .indexOf(evnt)]
                                            .companyID) {
                                      tk = await context
                                          .read<UserManager>()
                                          .getToken(eventProvider
                                              .events[eventProvider.events
                                                  .indexOf(evnt)]
                                              .userID
                                              .toString());
                                    } else {
                                      tk = await context
                                          .read<UserManager>()
                                          .getToken(context
                                                  .read<UserManager>()
                                                  .findUserByCompanyID(
                                                      eventProvider
                                                          .events[eventProvider
                                                              .events
                                                              .indexOf(evnt)]
                                                          .companyID) ??
                                              '');
                                    }
                                  } else {
                                    tk = await context
                                        .read<UserManager>()
                                        .getToken(context
                                                .read<UserManager>()
                                                .findUserByCompanyID(
                                                    eventProvider
                                                        .events[eventProvider
                                                            .events
                                                            .indexOf(evnt)]
                                                        .companyID) ??
                                            '');
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPageEvent(
                                        groupId: eventProvider
                                            .events[eventProvider.events
                                                .indexOf(evnt)]
                                            .id
                                            .toString(),
                                        userName: context
                                                .read<UserManager>()
                                                .userapp
                                                ?.name ??
                                            '',
                                        userToken: tk,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Chat'),
                              ),
                            ],
                          ));
                },

                onLongPress: (details) {
                  final AppEvent evnt = details.appointments!.first;
                  final userid = context.read<UserManager>().userapp!.id;
                  if (evnt.serviceid!.isEmpty) return;
                  final username = context
                      .read<AdminUsersManager>()
                      .findUserappByID(evnt.userID.toString());

                  // final service = context
                  //     .read<ServiceManager>()
                  //     .findServiceByID(evnt.serviceid);

                  if (details.appointments == null ||
                      details.appointments!.length > 0 ||
                      evnt.userID != userid) return;

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EventDetails(
                            event: evnt,
                            username: username.name,
                            service: evnt.description as String,
                          )));
                },
              ),
            );
            // }
            // return Center(child: CircularProgressIndicator.adaptive());
          },
        ),
      ),
      //floatingActionButton: flatbt(context),
    );
  }

  FloatingActionButton flatbt(BuildContext context) {
    if (widget.homeclic! < 8) {
      return FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 255, 161, 0),
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEv(
              selectedDate: _calendarController.selectedDate,
              company: widget.company,
              homeclic: widget.homeclic,
              service: context
                  .read<ServiceManager>()
                  .findServiceByID(widget.serviceid),
            ),
          ),
        ),
      );
    } else {
      return FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {},
      );
    }
  }
}
