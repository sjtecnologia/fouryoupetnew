import 'package:flutter/material.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/service/service_manager.dart';
import 'package:fouryoupet/models/service/service_params.dart';
import 'package:fouryoupet/screens/services/components/services_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import '../../models/page_manager.dart';
import 'components/search_dialog.dart';

// ignore: must_be_immutable
class ServicesScreen extends StatelessWidget {
  final ServiceParams? serviceParams;
  final bool? categoring;
  final int? homeclic;

  ServicesScreen({Key? key, this.serviceParams, this.categoring, this.homeclic})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 111, 0),
        iconTheme: IconThemeData(color: Colors.white),
        title: Consumer<ServiceManager>(
          builder: (_, serviceManager, __) {
            if (serviceManager.search.isEmpty) {
              return const Text('Serviços',
                  style: TextStyle(color: Colors.white));
            } else {
              return LayoutBuilder(builder: (_, constraints) {
                return GestureDetector(
                  onTap: () async {
                    final search = await showDialog<String>(
                        context: context,
                        builder: (_) => SearchDialog(serviceManager.search));
                    if (search != null) {
                      serviceManager.search = search;
                    }
                  },
                  child: Text(serviceManager.search,
                      style: TextStyle(color: Colors.white)),
                );
              });
            }
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          Consumer<ServiceManager>(
            builder: (_, serviceManager, __) {
              if (serviceManager.search.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final search = await showDialog<String>(
                        context: context,
                        builder: (_) => SearchDialog(serviceManager.search));
                    if (search != null) {
                      serviceManager.search = search;
                    }
                  },
                );
              } else {
                return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      serviceManager.search = '';
                    });
              }
            },
          ),
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              if (userManager.adminEnabled && !(categoring ?? false)) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/edit_service');
                  },
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),
      body: Container(
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
        child: Consumer2<ServiceManager, UserManager>(
          builder: (_, serviceManager, usersManager, __) {
            if (serviceParams != null) {
              serviceManager.categoryid = serviceParams!.categoryid;
            } else {
              serviceManager.categoryid = '0';
            }
            if (serviceParams != null) {
              serviceManager.companyID = serviceParams!.companyid;
            } else {
              serviceManager.companyID = usersManager.userapp!.companyID;
            }
            final filteredServices = serviceManager.filteredServicescompany;
            if (usersManager.isLoggedIn) {
              return ListView.builder(
                itemCount: filteredServices.length,
                itemBuilder: (_, index) {
                  return ServiceListTile(
                    filteredServices[index],
                    serviceParams?.companyid,
                    homeclic: homeclic,
                  );
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
// Removido bloco duplicado do método build/body
}
