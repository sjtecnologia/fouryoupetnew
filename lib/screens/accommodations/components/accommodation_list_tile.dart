import 'package:flutter/material.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../hotel/add_ht.dart';

class AccommodationListTile extends StatelessWidget {
  const AccommodationListTile(this.accommodation, this.company,
      {this.homeclic});

  final Accommodation accommodation;
  final String? company;
  final int? homeclic;

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return GestureDetector(
      onTap: () {
        if (homeclic == null) {
          Navigator.of(context)
              .pushNamed('/edit_acc', arguments: accommodation);
        } else {
          if (context.read<UserManager>().isLoggedIn) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddHt(
                          company: company,
                          homeclic: homeclic,
                          accommodation: accommodation,
                        )));
          } else {
            Navigator.of(context).pushNamed('/login');
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    accommodation.name!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Diária',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ ${formatter.format(accommodation.price)}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
