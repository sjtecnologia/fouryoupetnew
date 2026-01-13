import 'package:flutter/material.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/helpers/empty_card.dart';
import 'package:fouryoupet/helpers/login_card.dart';

import '../../common/hotel/event_tile.dart';

import '../../models/hotel/hotel_firestore_service.dart';
import '../../models/page_manager.dart';
import 'data/services/hotel_provider.dart';

class HotelScreen extends StatelessWidget {
  const HotelScreen({Key? key, this.company}) : super(key: key);
  final String? company;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    Userapp userapp = new Userapp();

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Hospedagens Hotelzinho',
            style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
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
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
              //Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer2<UserManager, HotelProvider>(
          builder: (_, userManager, hotelProvider, __) {
            if (userapp.id == null) {
              hotelProvider.updateUser(userManager.userapp, company);
              if (hotelProvider.user != null) userapp = hotelProvider.user!;
            }
            //eventProvider.updateUser(userManager.userapp);
            if (!userManager.isLoggedIn) {
              return LoginCard();
            }
            if (hotelProvider.hotel.isEmpty) {
              return const EmptyCard(
                title: 'Nenhuma hospedagem encontrada',
                iconData: Icons.border_clear,
              );
            }
            return ListView.builder(
                itemCount: hotelProvider.hotel.length,
                itemBuilder: (_, index) {
                  return Dismissible(
                    key: Key(hotelProvider.hotel.reversed
                        .toList()[index]
                        .id
                        .toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                          context: context,
                          builder: (context) {
                            DateTime today = DateTime.now();
                            DateTime dtini = hotelProvider.hotel.reversed
                                .toList()[index]
                                .ini_date!;
                            int dif = today.difference(dtini).inDays;
                            bool act = (dif < 1);
                            return AlertDialog(
                              title: Text(act
                                  ? 'Confirma o cancelamento?'
                                  : 'Tempo expirado para cancelamento'),
                              content: Text(act
                                  ? 'Esta ação não poderá ser desfeita'
                                  : 'Entre em contado com o Hotelzinho'),
                              actions: <Widget>[
                                Visibility(
                                  visible: (act),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Cancelar Hospedagem',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text(
                                    'Voltar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor),
                                ),
                              ],
                            );
                          });
                    },
                    onDismissed: (direction) {
                      DateTime today = DateTime.now();
                      DateTime dtini = hotelProvider.hotel.reversed
                          .toList()[index]
                          .ini_date!;
                      int dif = today.difference(dtini).inDays;
                      bool act = (dif < 1);
                      if (act)
                        hotelDBS.removeItem(hotelProvider.hotel.reversed
                            .toList()[index]
                            .id
                            .toString());
                    },
                    child: HotelTile(
                        hotelProvider.hotel.reversed.toList()[index],
                        showControls: false),
                  );
                });
          },
        ),
      ),
    );
  }
}
