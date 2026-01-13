import 'package:flutter/material.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/models/page_manager.dart';
import 'package:provider/provider.dart';

import 'custom_drawer_header.dart';
import 'drawer_tile.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 111, 0),
                Color.fromARGB(255, 255, 161, 0),
                //Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
          Consumer<PageManager>(
            builder: (_, pageManager, __) {
              return ListView(
                children: <Widget>[
                  CustomDrawerHeader(),
                  const Divider(),
                  const DrawerTile(
                    iconData: Icons.home,
                    title: 'Inicio',
                    page: 0,
                  ),
                  const DrawerTile(
                    iconData: Icons.shopify,
                    title: 'Meus Pedidos',
                    page: 1,
                  ),
                  const DrawerTile(
                      iconData: Icons.playlist_add_check,
                      title: 'Meus Agendamentos',
                      page: 2),
                  const DrawerTile(
                      iconData: Icons.hotel_outlined,
                      title: 'Minhas Hospedagens',
                      page: 3),
                  const DrawerTile(
                    iconData: Icons.pets,
                    title: 'Meus Pets',
                    page: 4,
                  ),
                  const DrawerTile(
                    iconData: Icons.account_box,
                    title: 'Dados da Conta',
                    page: 5,
                  ),
                  const DrawerTile(
                    iconData: Icons.location_pin,
                    title: 'Endereços',
                    page: 8,
                  ),
                  const DrawerTile(
                    iconData: Icons.star,
                    title: 'Programa de Fidelidade',
                    page: 13,
                  ),
                  const DrawerTile(
                    iconData: Icons.security_outlined,
                    title: 'Termos de Uso',
                    page: 9,
                  ),
                  if (context.read<UserManager>().userapp?.companyID == null ||
                      context.read<UserManager>().userapp?.companyID == '')
                    if (context.read<UserManager>().userapp != null)
                      const DrawerTile(
                        iconData: Icons.add_business,
                        title: 'Cadastrar seu Negócio pet',
                        page: 10,
                      ),
                  Consumer<UserManager>(
                    builder: (_, userManager, __) {
                      if (userManager.adminEnabled) {
                        return Column(
                          children: <Widget>[
                            const Divider(),
                            const DrawerTile(
                                iconData: Icons.business_sharp,
                                title: 'Dados Pet Shop',
                                page:
                                    19), // ✅ CORRIGIDO: página 19 para evitar duplicação
                            const DrawerTile(
                                iconData: Icons.business_center,
                                title: 'Produtos',
                                page: 11),
                            const DrawerTile(
                                iconData: Icons.cleaning_services_sharp,
                                title: 'Serviços',
                                page: 12),
                            const DrawerTile(
                                iconData: Icons.hotel,
                                title: 'Hospedagens',
                                page: 20),
                            const DrawerTile(
                                iconData: Icons.shopping_cart,
                                title: 'Pedidos',
                                page: 14),
                            const DrawerTile(
                                iconData: Icons.calendar_today,
                                title: 'Agendamentos Veterinários',
                                page: 15),
                            const DrawerTile(
                                iconData: Icons.calendar_today,
                                title: 'Agendamentos Cuidados',
                                page: 16),
                            const DrawerTile(
                                iconData: Icons.hotel_outlined,
                                title: 'Hospedagens Hotelzinho',
                                page: 17),
                            const DrawerTile(
                                iconData: Icons.schedule_send,
                                title: 'Manutenção de Agenda',
                                page: 18),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
