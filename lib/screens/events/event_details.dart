import 'package:flutter/material.dart';
import 'package:fouryoupet/models/event/event.dart';
import 'package:fouryoupet/models/event/event_firestore_service.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/page_manager.dart';

class EventDetails extends StatelessWidget {
  final AppEvent? event;
  final String? username;
  final String? service;

  const EventDetails({Key? key, this.event, this.username, this.service})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    num inprice = num.parse(event!.price!.toStringAsPrecision(2));
    String stprice = formatter.format(inprice);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Detalhes'),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //editar
              Navigator.pushReplacementNamed(context, 'edit_event',
                  arguments: event);
            },
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              // Se necessário, feche telas abertas
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Atenção'),
                      content: Text(
                          'Você tem certeza que quer excluir o agendamento?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text("Deletar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (confirm) {
                //delete and pop
                await eventDBS.removeItem(event!.id!);
                Navigator.pop(context);
              }
            },
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.event,
              color: Colors.white,
            ),
            title: Text(username! + ' - ' + event!.title!,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(event!.event_date!),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          // ignore: unnecessary_null_comparison
          if (event!.description != null)
            ListTile(
              leading: Icon(
                Icons.short_text,
                color: Colors.white,
              ),
              title: Text(
                event!.description ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Valor: ' + stprice,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}
