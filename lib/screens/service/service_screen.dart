import 'package:flutter/material.dart';
import 'package:fouryoupet/models/service/service.dart';
import 'package:fouryoupet/screens/events/data/services/event_provider.dart';
import 'package:fouryoupet/screens/events/event_screen.dart';

import 'package:fouryoupet/screens/service/components/size_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen(this.service);

  final Service? service;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);

    return ChangeNotifierProvider.value(
      value: service,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 111, 0),
          title: Text(service!.name!),
          centerTitle: true,
          actions: <Widget>[
            Container(
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
              child: Consumer<UserManager>(
                builder: (_, userManager, __) {
                  if (userManager.adminEnabled && !service!.deleted!) {
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                            '/edit_service',
                            arguments: service);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'R\$ ${formatter.format(service!.basePrice)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    service!.description!.toUpperCase(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (service!.deleted!)
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        'Indisponível',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red),
                      ),
                    )
                  else ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        'Detalhes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: service!.sizes!.map((s) {
                        return SizeWidget(size: s);
                      }).toList(),
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  Consumer2<UserManager, Service>(
                    builder: (_, userManager, service, __) {
                      return SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: service.selectedSize != null
                              ? () {
                                  if (userManager.isLoggedIn) {
                                    context.read<EventProvider>().events;
                                    final String cp = service.companyID ?? "";
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventScreen(
                                          company: cp,
                                          homeclic: 2,
                                          serviceid: service.id as String,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).pushNamed('/login');
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Theme.of(context).primaryColor.withAlpha(100),
                          ),
                          child: Text(
                            userManager.isLoggedIn
                                ? 'Agendamento'
                                : 'Entre para Agendar',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
