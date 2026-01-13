import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/store/stores_manager.dart';

import 'components/store_card.dart';

class StoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 161, 0),
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text('Lojas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Consumer<StoresManager>(
        builder: (_, storesManager, __) {
          if (storesManager.stores.isEmpty) {
            return const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              backgroundColor: Colors.transparent,
            );
          }

          return ListView.builder(
            itemCount: storesManager.stores.length,
            itemBuilder: (_, index) {
              return StoreCard(storesManager.stores[index]);
            },
          );
        },
      ),
    );
  }
}
