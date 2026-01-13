import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';

import 'package:screenshot/screenshot.dart';

class ExportAddressDialog extends StatelessWidget {
  ExportAddressDialog(this.address);

  final Address? address;

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Endereço de Entrega',
          style: TextStyle(color: Colors.white)),
      content: Screenshot(
        controller: screenshotController,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Text(
            '${address!.street}, ${address!.number} ${address!.complement}\n'
            '${address!.district}\n'
            '${address!.city}/${address!.state}\n'
            '${address!.zipCode}',
          ),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            /*    final file = await screenshotController.capture().toString();
            await GallerySaver.saveImage(file);*/
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          //textColor: Theme.of(context).primaryColor,
          child: const Text('Exportar'),
        )
      ],
    );
  }
}
