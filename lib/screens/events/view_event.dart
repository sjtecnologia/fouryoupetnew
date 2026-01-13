import 'package:flutter/material.dart';
import 'package:fouryoupet/models/event/event.dart';
import 'package:provider/provider.dart';

import '../../models/page_manager.dart';

class EventDetailsPage extends StatelessWidget {
  final AppEvent? event;

  const EventDetailsPage({Key? key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Text(event.title, style: Theme.of(context).textTheme.display1,),
            SizedBox(height: 20.0),
            Text(event!.description as String)
          ],
        ),
      ),
    );
  }
}
