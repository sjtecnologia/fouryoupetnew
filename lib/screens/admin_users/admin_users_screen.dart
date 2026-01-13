import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/admin/admin_orders_manager.dart';
import 'package:fouryoupet/models/admin/admin_users_manager.dart';
import 'package:fouryoupet/models/page_manager.dart';

class AdminUsersSreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Usuários'),
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
        child: Consumer<AdminUsersManager>(builder: (_, adminUsersManager, __) {
          return AlphabetListScrollView(
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(
                  adminUsersManager.users[index].name!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.white),
                ),
                subtitle: Text(
                  adminUsersManager.users[index].email!,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  context
                      .read<AdminOrdersManager>()
                      .setUserFilter(adminUsersManager.users[index]);
                  context.read<PageManager>().setPage(5);
                },
              );
            },
            highlightTextStyle:
                const TextStyle(color: Colors.white, fontSize: 20),
            indexedHeight: (index) => 80,
            strList: adminUsersManager.names,
            showPreview: true,
          );
        }),
      ),
    );
  }
}
