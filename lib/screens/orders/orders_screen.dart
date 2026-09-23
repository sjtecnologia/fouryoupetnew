import 'package:flutter/material.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/order/orders_manager.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/common/login_card.dart';
import 'package:fouryoupet/common/empty_card.dart';
import 'package:fouryoupet/common/order/order_tile.dart';
import '../../models/page_manager.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: const Text('Meus Pedidos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<OrdersManager>(
          builder: (_, ordersManager, __) {
            if (ordersManager.user == null) {
              return RefreshIndicator(
                onRefresh: () async {
                  ordersManager.updateUser(ordersManager.user);
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: LoginCard(),
                  ),
                ),
              );
            }
            if (ordersManager.orders.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  ordersManager.updateUser(ordersManager.user);
                },
                color: primaryColor,
                backgroundColor: Colors.white,
                strokeWidth: 3.0,
                displacement: 40.0,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: const EmptyCard(
                      title: 'Nenhuma compra encontrada',
                      iconData: Icons.border_clear,
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ordersManager.updateUser(ordersManager.user);
              },
              color: primaryColor,
              backgroundColor: Colors.white,
              strokeWidth: 3.0,
              displacement: 40.0,
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: ordersManager.orders.length,
                itemBuilder: (_, index) {
                  DateTime today = DateTime.now();
                  DateTime dtevent = ordersManager.orders.reversed
                      .toList()[index]
                      .date!
                      .toDate();
                  int dif = today.difference(dtevent).inHours;
                  bool act = (dif < 1);
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(act
                                ? 'Confirma o cancelamento?'
                                : 'Tempo expirado para cancelamento'),
                            content: Text(act
                                ? 'Esta ação não poderá ser desfeita'
                                : 'Entre em contato com o Petshop'),
                            actions: <Widget>[
                              Visibility(
                                visible: (act),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Cancelar Pedido',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                ),
                                replacement: const Text(
                                  'Tempo para cancelamento é de no máximo 1 hora após a compra',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
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
                        },
                      );
                    },
                    onDismissed: (direction) {
                      ordersManager.orders.reversed.toList()[index].cancel();
                    },
                    child: OrderTile(
                        ordersManager.orders.reversed.toList()[index]),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }}