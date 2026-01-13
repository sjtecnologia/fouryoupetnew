import 'package:flutter/material.dart';
import 'package:fouryoupet/models/page_manager.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/screens/address/addresss_screen.dart';
import 'package:fouryoupet/screens/loyalty/loyalty_screen.dart';
import 'package:fouryoupet/screens/userterm/userterm_screen.dart';
import 'package:fouryoupet/screens/company/new_company_screen.dart';
import 'package:fouryoupet/screens/edit_company/edit_company_screen.dart';
import 'package:fouryoupet/screens/products/products_screen.dart';
import 'package:fouryoupet/screens/services/services_screen.dart';
import 'package:fouryoupet/screens/accommodations/accommodations_screen.dart';
import 'package:fouryoupet/screens/orders/orders_screen.dart';
import 'package:fouryoupet/screens/schedule/Available_Time_Form.dart';
import 'package:fouryoupet/screens/events/event_screen.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/product/product_manager.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    Key? key,
    this.iconData,
    this.title,
    this.page,
  }) : super(key: key);

  final IconData? iconData;
  final String? title;
  final int?
      page; // Continua como int? para compatibilidade com o construtor original

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para acessar o PageManager e reconstruir apenas o necessário
    return Consumer<PageManager>(
      builder: (context, pageManager, child) {
        final int currentPage = pageManager.page;
        final bool isSelected = currentPage == page;

        final Color iconColor =
            isSelected ? Theme.of(context).primaryColor : Colors.grey[900]!;
        final Color textColor =
            isSelected ? Theme.of(context).primaryColor : Colors.grey[900]!;

        return InkWell(
          onTap: () async {
            if (page != null) {
              if (page != null && page! >= 0 && page! <= 7) {
                pageManager.setPage(page!);
                Navigator.of(context).pop(); // Fecha o drawer após a navegação
              } else if (page == 8) {
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddresssScreen()),
                );
              } else if (page == 9) {
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => UsertermScreen()),
                );
              } else if (page == 10) {
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NewCompanyScreen()),
                );
              } else if (page == 11) {
                // Produtos
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                final userManager = context.read<UserManager>();
                final companyID = userManager.userapp?.companyID;
                if (companyID != null) {
                  final productManager = context.read<ProductManager>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductsScreen(
                        companyid: companyID,
                        productManager: productManager,
                      ),
                    ),
                  );
                }
              } else if (page == 12) {
                // Serviços
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ServicesScreen(),
                  ),
                );
              } else if (page == 13) {
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LoyaltyScreen()),
                );
              } else if (page == 14) {
                // Pedidos
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => OrdersScreen()),
                );
              } else if (page == 15) {
                // Agendamentos Veterinários
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                final userManager = context.read<UserManager>();
                final companyID = userManager.userapp?.companyID;
                if (companyID != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventScreen(
                        company: companyID,
                        homeclic: 8,
                        serviceid: '',
                      ),
                    ),
                  );
                }
              } else if (page == 16) {
                // Agendamentos Cuidados
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                final userManager = context.read<UserManager>();
                final companyID = userManager.userapp?.companyID;
                if (companyID != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventScreen(
                        company: companyID,
                        homeclic: 1,
                        serviceid: '',
                      ),
                    ),
                  );
                }
              } else if (page == 17 || page == 20) {
                // Hospedagens Hotelzinho e Hospedagens
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AccommodationsScreen(),
                  ),
                );
              } else if (page == 18) {
                // Manutenção de Agenda
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                final userManager = context.read<UserManager>();
                final companyID = userManager.userapp?.companyID;
                if (companyID != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AvailableTimeForm(
                        company: companyID,
                      ),
                    ),
                  );
                }
              } else if (page == 19) {
                await Navigator.of(context).maybePop();
                await Future.delayed(Duration(milliseconds: 200));
                final userManager = context.read<UserManager>();
                final companyID = userManager.userapp?.companyID;
                if (companyID != null) {
                  // Busca a empresa atual do usuário
                  final companyManager = context.read<CompanyManager>();
                  final company =
                      await companyManager.findCompanyByID(companyID);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => EditCompanyScreen(company)),
                  );
                }
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          child: SizedBox(
            height: 60,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Icon(
                    iconData,
                    size: 32,
                    color: iconColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    title ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
