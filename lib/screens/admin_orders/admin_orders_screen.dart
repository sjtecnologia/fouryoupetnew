import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/common/custom_icon_button.dart';
import 'package:fouryoupet/common/empty_card.dart';
import 'package:fouryoupet/models/admin/admin_orders_manager.dart';
import 'package:fouryoupet/common/order/order_tile.dart';
import 'package:fouryoupet/models/order/order.dart';

import '../../models/page_manager.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Todos os Pedidos',
            style: TextStyle(color: Colors.white)),
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
        child: Consumer<AdminOrdersManager>(
          builder: (_, ordersManager, __) {
            final filteredOrders = ordersManager.filteredOrders;

            return SlidingUpPanel(
              controller: panelController,
              body: Column(
                children: <Widget>[
                  if (ordersManager.userFilter != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Pedidos de ${ordersManager.userFilter!.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          CustomIconButton(
                            iconData: Icons.close,
                            color: Colors.white,
                            onTap: () {
                              ordersManager.setUserFilter(null);
                            },
                          )
                        ],
                      ),
                    ),
                  if (filteredOrders.isEmpty)
                    EmptyCard(
                      title: 'Nenhuma venda realizada!',
                      iconData: Icons.border_clear,
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                          itemCount: filteredOrders.length,
                          itemBuilder: (_, index) {
                            return OrderTile(
                              filteredOrders[index],
                              showControls: true,
                            );
                          }),
                    ),
                  const SizedBox(
                    height: 120,
                  ),
                ],
              ),
              minHeight: 50,
              maxHeight: 300,
              panel: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (panelController.isPanelClosed) {
                        panelController.open();
                      } else {
                        panelController.close();
                      }
                    },
                    child: Container(
                      height: 40,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text(
                        'Filtros',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: Status.values.map((s) {
                        return CheckboxListTile(
                          title: Text(Order.getStatusText(s)),
                          dense: true,
                          activeColor: Theme.of(context).primaryColor,
                          value: ordersManager.statusFilter.contains(s),
                          onChanged: (v) {
                            ordersManager.setStatusFilter(
                                status: s, enabled: v!);
                          },
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
