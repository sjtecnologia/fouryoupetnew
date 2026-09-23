import 'package:flutter/material.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';
import 'package:fouryoupet/models/accommodation/accommodation_manager.dart';
import 'package:fouryoupet/models/accommodation/accommodation_params.dart';

import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import '../../common/custom_drawer/custom_drawer.dart';
import '../../models/page_manager.dart';

import 'components/accommodation_list_tile.dart';
import 'components/search_dialog.dart';

// ignore: must_be_immutable
class AccommodationsScreen extends StatefulWidget {
  AccommodationsScreen(
      {this.accommodationParams, this.categoring, this.homeclic});

  AccommodationParams? accommodationParams;

  final bool? categoring;
  final int? homeclic;

  @override
  State<AccommodationsScreen> createState() => _AccommodationsScreenState();
}

class _AccommodationsScreenState extends State<AccommodationsScreen> {
  List<Accommodation> filteredAc = [];
  String? _lastFetchCompanyId;

  void _ensureFetchForCompany(String companyId) {
    if (companyId.isEmpty || _lastFetchCompanyId == companyId) return;
    _lastFetchCompanyId = companyId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccommodationManager>().fetchAccommodations();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accommodationManager = context.read<AccommodationManager>();
      final usersManager = context.read<UserManager>();

      if (widget.accommodationParams != null) {
        accommodationManager.companyID = widget.accommodationParams!.companyid;
      } else {
        accommodationManager.companyID = usersManager.userapp?.companyID ?? '';
      }

      if (widget.accommodationParams != null) {
        accommodationManager.categoryid =
            widget.accommodationParams!.categoryid;
      } else {
        accommodationManager.categoryid = '0';
      }

      _ensureFetchForCompany(accommodationManager.companyID ?? '');

      accommodationManager.fetchAccommodations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: (widget.categoring == false || widget.categoring == null)
          ? CustomDrawer()
          : null,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 111, 0),
        iconTheme: IconThemeData(color: Colors.white),
        title: Consumer<AccommodationManager>(
          builder: (_, accommodationManager, __) {
            if (accommodationManager.search.isEmpty) {
              return const Text('Hospedagens',
                  style: TextStyle(color: Colors.white));
            } else {
              return GestureDetector(
                onTap: () async {
                  final search = await showDialog<String>(
                      context: context,
                      builder: (_) =>
                          SearchDialog(accommodationManager.search));
                  if (search != null) {
                    accommodationManager.search = search;
                  }
                },
                child: Text(
                  accommodationManager.search,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          Consumer<AccommodationManager>(
            builder: (_, accommodationManager, __) {
              if (accommodationManager.search.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final search = await showDialog<String>(
                        context: context,
                        builder: (_) =>
                            SearchDialog(accommodationManager.search));
                    if (search != null) {
                      accommodationManager.search = search;
                    }
                  },
                );
              } else {
                return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      accommodationManager.search = '';
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
              if (userManager.adminEnabled &&
                  (widget.categoring == false || widget.categoring == null)) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/edit_acc',
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
        child: Consumer2<AccommodationManager, UserManager>(
            builder: (_, accommodationManager, usersManager, __) {
          final targetCategory = widget.accommodationParams?.categoryid ?? '0';
          final targetCompany = widget.accommodationParams?.companyid ??
              (usersManager.userapp?.companyID ?? '');

          if (accommodationManager.categoryid != targetCategory) {
            accommodationManager.categoryid = targetCategory;
          }
          if (accommodationManager.companyID != targetCompany) {
            accommodationManager.companyID = targetCompany;
          }

          _ensureFetchForCompany(targetCompany);

          final filteredAcc = accommodationManager.filteredAccs;

          if (filteredAcc.isNotEmpty)
            return ListView.builder(
                itemCount: filteredAcc.length,
                itemBuilder: (_, index) {
                  return AccommodationListTile(
                      filteredAcc[index], filteredAcc.last.companyID,
                      homeclic: widget.homeclic);
                });
          return Container();
        }),
      ),
    );
  }
}
