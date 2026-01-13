import 'package:flutter/material.dart';
import 'package:fouryoupet/models/order/order.dart';

class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog(this.order);

  final Order order;

  @override
  _CancelOrderDialogState createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        title: Text(
          'Cancelar pedido ${widget.order.formattedId} ?',
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
                      await widget.order.cancel();
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
              'Cancelar Pedido',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
