import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fouryoupet/models/company/company.dart';

import 'package:fouryoupet/screens/categories/categories_screen.dart';
import 'package:fouryoupet/screens/companys/components/status_company_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/cart/cart_manager.dart';
import '../../../models/user/user_manager.dart';

class CompanyListTile extends StatelessWidget {
  const CompanyListTile(this.company, {this.homeclic});

  final Company company;
  final int? homeclic;

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat("0.0# KM", "pt_BR");
    return GestureDetector(
      onTap: () {
        var userap = context.read<UserManager>().userapp;
        var cpid = context.read<CartManager>().items.length > 0
            ? context.read<CartManager>().items.last.companyID
            : null;
        if (userap != null) {
          if (cpid != null && cpid != company.id) {
            _showAlertDialog(context);
            context.read<CartManager>().clear();
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoriesScreen(
                          company: company,
                          homeclic: homeclic,
                        )));
          }
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategoriesScreen(
                        company: company,
                        homeclic: homeclic,
                      )));
        }
      },
      child: Card(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          height: MediaQuery.of(context).size.height * .180, //110,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  company.images!.first,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * .5,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      company.name!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (company.id != '0')
                    if (company.address != null)
                      if (company.address?.street != null)
                        Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          company.address!.street!.toUpperCase() +
                              ' - ' +
                              company.address!.number.toString() +
                              ' - ' +
                              company.address!.district!.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black45),
                        ),
                  if (company.id != '0')
                    Text(
                      company.delivery ?? true == true
                          ? company.prazoentrega ?? '...'
                          : 'Somente retirada',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black45),
                    ),
                  if (company.id != '0')
                    Row(
                      children: [
                        StatusCompanyText(
                          abertura: company.abertura ?? '',
                          fechamento: company.fechamento ?? '',
                          daysoff: company.daysoff ?? [],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          f.format(company.distancia),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black45),
                        ),
                      ],
                    )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  _showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        context.read<CartManager>().clear();
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoriesScreen(
                      company: company,
                      homeclic: homeclic,
                    )));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alerta"),
      content: Text(
          "Se você mudar de Fornecedor seu carrinho atual será zerado, deseja continuar?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ScaleSize {
  static double textScaleFactor(BuildContext context,
      {double maxTextScaleFactor = 2}) {
    final width = MediaQuery.of(context).size.width;
    double val = (width / 2500) * maxTextScaleFactor;
    return max(1, min(val, maxTextScaleFactor));
  }
}
