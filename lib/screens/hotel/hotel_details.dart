import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/hotel/hotel.dart';
import '../../models/hotel/hotel_firestore_service.dart';
import '../../models/page_manager.dart';

class HotelDetails extends StatelessWidget {
  final Hotel? hotel;
  final String? username;
  final String? acc;

  const HotelDetails({Key? key, this.hotel, this.username, this.acc})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    num inprice = num.parse(hotel!.price!.toStringAsPrecision(2));
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
              Navigator.pushReplacementNamed(context, 'edit_hotel',
                  arguments: hotel);
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
                          'Você tem certeza que quer excluir a hospedagem?'),
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
                await hotelDBS.removeItem(hotel!.id!);
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
            title: Text(username!,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(hotel!.ini_date!) +
                  ' até ' +
                  DateFormat('dd/MM/yyyy HH:mm').format(hotel!.end_date!),
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
          ListTile(
            leading: Icon(
              Icons.short_text,
              color: Colors.white,
            ),
            title: Text(
              'Hotelzinho',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Diária: ' + stprice,
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
