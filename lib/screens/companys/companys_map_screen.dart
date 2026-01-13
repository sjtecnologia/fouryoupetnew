import 'package:flutter/material.dart';
import 'package:fouryoupet/models/company/company_manager.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'components/companys_list_tile.dart';

class CompanysMapScreen extends StatelessWidget {
  const CompanysMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final szct = MediaQuery.of(context).size.height * .30;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Fornecedores2',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ChangeNotifierProvider<CompanyManager>(
          create: (context) => CompanyManager(),
          child: Builder(
            builder: (context) {
              //final local = context.watch<UserManager>();
              final companys = context.watch<CompanyManager>();
              companys.homeclic = 1;
              final filteredCompanys = companys.filteredCompanys;

              return Column(
                children: [
                  Container(
                    height: szct, //MediaQuery.of(context).size.height * .30,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            companys.lat,
                            companys.long,
                          ),
                          zoom: 18,
                        ),
                        zoomControlsEnabled: true,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        onMapCreated: companys.onMapCreated,
                        markers: companys.markers,
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * .5,
                    //width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCompanys.length,
                        itemBuilder: (_, index) {
                          return CompanyListTile(
                            filteredCompanys[index],
                            homeclic: 1,
                          );
                        }),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
