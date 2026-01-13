import 'package:flutter/material.dart';
import 'package:fouryoupet/models/service/service_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Vincular Serviço'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Consumer<ServiceManager>(
        builder: (_, serviceManager, __) {
          return ListView.builder(
            itemCount: serviceManager.services.length,
            itemBuilder: (_, index) {
              final service = serviceManager.services[index];
              return ListTile(
                //leading: Image.network(service.images!.first),
                title: Text(service.name!),
                subtitle: Text('R\$ ${formatter.format(service.basePrice)}'),
                onTap: () {
                  Navigator.of(context).pop(service);
                },
              );
            },
          );
        },
      ),
    );
  }
}
