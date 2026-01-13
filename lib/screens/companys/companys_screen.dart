// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fouryoupet/common/empty_card.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/screens/companys/components/companys_list_tile.dart';

import '../../models/page_manager.dart';

import 'components/search_dialog.dart';

final appKey = GlobalKey();

// ignore: must_be_immutable
class CompanysScreen extends StatefulWidget {
  CompanysScreen({
    Key? key,
    this.homeclic,
  }) : super(key: key);

  final int? homeclic;

  @override
  State<CompanysScreen> createState() => _CompanysScreenState();
}

class _CompanysScreenState extends State<CompanysScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CustomDrawer();
    return Scaffold(
      key: appKey,
      extendBodyBehindAppBar: true,
      // Remover o drawer para não exibir o menu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true, // Mostra o botão de voltar
        title: Consumer<CompanyManager>(
          builder: (_, companyManager, __) {
            return const Text('Fornecedores',
                style: TextStyle(color: Colors.white));
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          Consumer<CompanyManager>(
            builder: (_, companyManager, __) {
              if (companyManager.search.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final search = await showDialog<String>(
                      context: context,
                      builder: (_) => FocusScope(
                          child: SearchDialog(companyManager.search)),
                    );
                    if (search != null) {
                      companyManager.search = search;
                    }
                  },
                );
              } else {
                return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      companyManager.search = '';
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top),
              Consumer<CompanyManager>(
                builder: (_, companyManager, __) {
                  return Visibility(
                    visible: context.read<CompanyManager>().permissao ==
                            LocationPermission.whileInUse ||
                        context.read<CompanyManager>().permissao ==
                            LocationPermission.always,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .35,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 18, left: 14, right: 14),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              companyManager.lat,
                              companyManager.long,
                            ),
                            zoom: 13,
                          ),
                          zoomControlsEnabled: true,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          onMapCreated:
                              context.read<CompanyManager>().onMapCreated,
                          markers: context.read<CompanyManager>().markers,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final permissao = context.read<CompanyManager>().permissao;
                  final double height =
                      (permissao == LocationPermission.whileInUse ||
                              permissao == LocationPermission.always)
                          ? MediaQuery.of(context).size.height * .55
                          : MediaQuery.of(context).size.height * .83;
                  return Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Consumer<CompanyManager>(
                      builder: (_, companyManager, __) {
                        companyManager.homeclic = this.widget.homeclic;
                        if (companyManager.loading) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orangeAccent),
                            ),
                          );
                        }
                        if (companyManager.filteredCompanys.isNotEmpty) {
                          return ListView.builder(
                              itemCount: companyManager.filteredCompanys.length,
                              itemBuilder: (_, index) {
                                if (companyManager.filteredCompanys.length >=
                                    1) {
                                  return CompanyListTile(
                                    companyManager.filteredCompanys[index],
                                    homeclic: this.widget.homeclic,
                                  );
                                } else
                                  return EmptyCard(
                                    title:
                                        'Nenhum forncedor encontrado para o seu endereço',
                                    iconData: Icons.border_clear,
                                  );
                              });
                        } else {
                          return EmptyCard(
                            title:
                                'Nenhum forncedor encontrado para o seu endereço',
                            iconData: Icons.border_clear,
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: flatbt(context),
    );
  }

  FloatingActionButton flatbt(BuildContext context) {
    if (widget.homeclic == 1) {
      return FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pushNamed('/cart');
        },
        child: const Icon(Icons.shopping_cart),
      );
    } else {
      return FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {},
      );
    }
  }
}
