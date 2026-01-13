import 'package:flutter/material.dart';

import 'package:fouryoupet/models/notificatificacao/notifications_manager.dart';
import 'package:provider/provider.dart';

import '../../common/custom_drawer/custom_drawer.dart';
import '../../common/empty_card.dart';
import '../../common/login_card.dart';

import '../../models/page_manager.dart';
import '../../models/user/user_manager.dart';
import 'notifications_tile.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<NotificationsManager>().stNotific();
    });
  }

  @override
  Widget build(BuildContext context) {
  // final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: const Text('Notificações', style: TextStyle(color: Colors.white)),
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
        child: Consumer2<NotificationsManager, UserManager>(
          builder: (_, notificationsManager, usersManager, __) {
            if (!usersManager.isLoggedIn) {
              return LoginCard();
            } else if (notificationsManager.notifications?.notif == null ||
                notificationsManager.notifications == null ||
                notificationsManager.notifications?.notif?.length == 0) {
              return const EmptyCard(
                title: 'Nenhuma notificação encontrada',
                iconData: Icons.border_clear,
              );
            } else {
              return ListView.builder(
                itemCount: notificationsManager.notifications?.notif?.length ?? 0,
                itemBuilder: (_, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirma a Exclusão'),
                            content: Text('Esta ação não poderá ser desfeita'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(
                                  'Excluir Notificação',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Voltar',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) async {
                      notificationsManager.notifications?.notif?.removeAt(index);
                      notificationsManager
                          .updatentf(notificationsManager.notifications);
                    },
                    child: GestureDetector(
                      onTap: () {
                        notificationsManager.notifications!.notif!
                            .toList()[index]
                            .lido = true;
                        notificationsManager
                            .updatentf(notificationsManager.notifications);
                        notificationsManager.updateUser(usersManager.userapp);
                        setState(() {});
                      },
                      child: notificationsManager.notifications?.notif?.length != 0 &&
                              notificationsManager.notifications?.notif != null
                          ? NotificationsTile(notificationsManager.notifications!.notif!.toList()[index])
                          : Container(),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }}