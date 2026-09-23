import 'package:flutter/material.dart';
import 'package:fouryoupet/common/empty_card.dart';
import 'package:fouryoupet/models/service/service.dart';
import 'package:fouryoupet/models/service/service_manager.dart';

import 'package:fouryoupet/screens/services/components/services_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/page_manager.dart';
import 'components/search_dialog.dart';

// ignore: must_be_immutable
class ServicesScreencp extends StatelessWidget {
  ServicesScreencp(
      {this.categoring, this.homeclic, this.categoria, this.companyid});

  final bool? categoring;
  final int? homeclic;
  final String? companyid;
  final String? categoria;

  List<Service> filteredService2 = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  child: Text(
                    serviceManager.search,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
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
              // Se necessário, feche telas abertas
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              if (userManager.adminEnabled && !categoring!) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/edit_service',
                    );
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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
          if (homeclic != 3) {
            serviceManager.dateEvent = DateTime.now();
            if (this.categoria != null)
              serviceManager.categoryid = this.categoria;
            else
              serviceManager.categoryid = '0';
            if (this.companyid != null)
              serviceManager.companyID = this.companyid;
            else
              serviceManager.companyID = usersManager.userapp!.companyID;
          } else {
            if (this.categoria != null)
              serviceManager.categoryid = this.categoria;
            else
              serviceManager.categoryid = '0';
            if (this.companyid != null)
              serviceManager.companyID = this.companyid;
            else
              serviceManager.companyID = usersManager.userapp!.companyID;
          }
          if (homeclic != 3) {
            filteredService2 = serviceManager.filteredServicescpct;
          } else {
            filteredService2 = serviceManager.filteredServicesvet;
          }
          final filteredServices = filteredService2;

          return Column(
            children: [
              if (filteredServices.isNotEmpty)
                Expanded(
                  child: Skeletonizer(
                    enabled: serviceManager.loading,
                    child: ListView.builder(
                        itemCount: filteredServices.length,
                        itemBuilder: (_, index) {
                          return ServiceListTile(
                              filteredServices[index], this.companyid,
                              homeclic: homeclic);
                        }),
                  ),
                )
              else
                Expanded(
                  child: serviceManager.loading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orangeAccent),
                          ),
                        )
                      : EmptyCard(
                          title: 'Nenhum cuidado encontrado',
                          iconData: Icons.border_clear,
                        ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
