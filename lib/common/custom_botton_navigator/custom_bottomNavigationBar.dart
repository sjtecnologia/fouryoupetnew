import 'package:flutter/material.dart';
import 'package:fouryoupet/models/notificatificacao/notifications_manager.dart';
import 'package:fouryoupet/screens/homenew/home_screen.dart';
import 'package:provider/provider.dart';

import '../../helpers/mysearch_pagenew.dart';
import '../../models/page_manager.dart';
import '../../screens/events/events_screen.dart';
import '../../screens/notificacoes/notifications_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/pets/pets_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  CustomBottomNavigationBar();

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final PageController pageController = PageController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<NotificationsManager>().stNotificnolido();
    });
    super.initState();
  }

  _CustomBottomNavigationBarState();

  int currentIndex = 0;
  final screens = [
    HomeScreen(),
    OrdersScreen(),
    EventsScreen(),
    PetsScreen(),
    NotificationsScreen(),
    MySearchPageNew(),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // REMOVIDO: Provider<PageManager> - agora usamos Consumer para acessar o singleton
    return Consumer<PageManager>(
      builder: (context, pageManager, child) {
        return FutureBuilder<int?>(
          future: NotificationsManager().stNotificnolido(),
          builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
            return BottomNavigationBar(
              selectedFontSize: 9,
              unselectedFontSize: 9,
              type: BottomNavigationBarType.fixed,
              currentIndex: pageManager
                  .page, // Usando pageManager.page em vez de currentIndex
              onTap: (pagina) {
                _onItemTapped(pagina, pageManager);
                pageController.animateToPage(
                  pagina,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                );
              },
              selectedItemColor: primaryColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopify),
                  label: 'Pedidos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Agendamentos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.hotel),
                  label: 'Hospedagens',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pets_sharp),
                  label: 'Meus Pets',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text(
                        snapshot.data != null ? snapshot.data.toString() : '0'),
                    isLabelVisible: snapshot.data != 0 && snapshot.data != null,
                    child: Icon(Icons.notification_important_sharp),
                  ),
                  label: 'Notificações',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Busca',
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index, PageManager pageManager) {
    setState(() {
      context.read<NotificationsManager>().stNotificnolido();
      currentIndex = index;
    });

    // Atualiza o PageManager também
    pageManager.setPage(index);

    // switch (index) {
    //   case 0:
    //     Navigator.of(context).pushNamed('/home');
    //     break;
    //   case 1:
    //     Navigator.of(context).pushNamed('/orders');
    //     break;
    //   case 2:
    //     Navigator.of(context).pushNamed('/myevents');
    //     break;
    //   case 3:
    //     Navigator.of(context).pushNamed('/myhotels');
    //     break;
    //   case 4:
    //     Navigator.pushAndRemoveUntil(
    //         context,
    //         MaterialPageRoute(builder: (BuildContext context) => ScreenPet()),
    //         ModalRoute.withName('/pet'));

    //     //Navigator.of(context).pushNamed('/pet');
    //     break;
    //   case 5:
    //     context.read<NotificationsManager>().stNotific();
    //     Navigator.of(context).pushNamed('/notifications');
    //     break;
    //   default:
    // }
  }
}
