import 'package:flutter/material.dart';
import 'package:fouryoupet/models/event/event.dart';

class CancelEventDialog extends StatefulWidget {
  const CancelEventDialog(this.event);

  final AppEvent event;

  @override
  _CancelEventDialogState createState() => _CancelEventDialogState();
}

class _CancelEventDialogState extends State<CancelEventDialog> {
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        title: Text(
          'Cancelar Agendamento ?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(loading
                ? 'Cancelando...'
                : 'Esta ação não poderá ser desfeita!'),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: !loading
                ? () {
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text(
              'Voltar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: !loading
                ? () async {
                    setState(() {
                      loading = true;
                    });
                    try {
                      Navigator.of(context).pop();
                    } catch (e) {
                      setState(() {
                        loading = false;
                        error = e.toString();
                      });
                    }
                  }
                : null,
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Cancelar Agendamento',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
