import 'package:flutter/material.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/service/service.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../events/add_ev.dart';

class ServiceListTile extends StatelessWidget {
  const ServiceListTile(this.service, this.company, {this.homeclic});

  final Service service;
  final String? company;
  final int? homeclic;

  @override
  Widget build(BuildContext context) {
    //final wd = MediaQuery.of(context).size.width;
    String? cpname = context
            .read<CompanyManager>()
            .findCompanyByID(service.companyID)
            ?.name ??
        '';
    final hd = MediaQuery.of(context).size.height;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    return GestureDetector(
      onTap: () {
        if (homeclic == null) {
          Navigator.of(context).pushNamed('/edit_service', arguments: service);
        } else {
          if (context.read<UserManager>().isLoggedIn) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddEv(
                          company: company,
                          homeclic: homeclic,
                          service: service,
                        )));
          } else {
            Navigator.of(context).pushNamed('/login');
          }
        }
      },
      child: Visibility(
        visible: (service.basePrice! > 0),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            height: hd * .23,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      service.name!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      service.description!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'R\$ ${formatter.format(service.basePrice ?? 0)}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor),
                    ),
                    Visibility(
                      visible: cpname != "",
                      child: Text(
                        'Vendedor - ' + cpname,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
