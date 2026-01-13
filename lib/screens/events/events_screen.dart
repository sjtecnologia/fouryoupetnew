import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/common/event/event_tile.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:fouryoupet/screens/events/data/services/event_provider.dart';
import 'package:provider/provider.dart';

import 'package:fouryoupet/helpers/empty_card.dart';
import 'package:fouryoupet/helpers/login_card.dart';

import '../../models/page_manager.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    Userapp userapp = Userapp();

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: const Text('Meus Agendamentos',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            // ...existing code...
            if (userapp.id == null) {
              eventProvider.updateUser(userManager.userapp, false, 0);
              if (eventProvider.user != null) userapp = eventProvider.user!;
            }
            if (!userManager.isLoggedIn) {
              return LoginCard();
            }
            final evenst = eventProvider.events;
            if (evenst.isEmpty) {
              return const EmptyCard(
                title: 'Nenhum agendamento encontrado',
                iconData: Icons.border_clear,
              );
            }
            return ListView.builder(
                itemCount: eventProvider.events.length,
                itemBuilder: (_, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                          context: context,
                          builder: (context) {
                            DateTime today = DateTime.now();
                            DateTime dtevent = eventProvider.events.reversed
                                .toList()[index]
                                .event_date!;
                            int dif = today.difference(dtevent).inHours;
                            bool act = (dif < 1);
                            return AlertDialog(
                              title: Text(act
                                  ? 'Confirma o cancelamento?'
                                  : 'Tempo expirado para cancelamento ou cancelamento já efetuado!'),
                              content: Text(act
                                  ? 'Esta ação não poderá ser desfeita'
                                  : 'Entre em contado com o Petshop'),
                              actions: <Widget>[
                                Visibility(
                                  visible: (act),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Cancelar Agendamento',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text(
                                    'Voltar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor),
                                ),
                              ],
                            );
                          });
                    },
                    onDismissed: (direction) async {
                      DateTime today = DateTime.now();
                      DateTime dtevent = eventProvider.events.reversed
                          .toList()[index]
                          .event_date!;
                      int dif = today.difference(dtevent).inHours;
                      bool act = (dif < 1);
                      if (act)
                        await eventProvider.events.reversed
                            .toList()[index]
                            .cancel();
                      eventProvider.updateUser(userManager.userapp, false, 0);
                    },
                    child: EventTile(
                        eventProvider.events.reversed.toList()[index]),
                  );
                });
          },
        ),
      ),
    );
  }
}
