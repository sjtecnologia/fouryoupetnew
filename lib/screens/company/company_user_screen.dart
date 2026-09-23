import 'package:flutter/material.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/company/company.dart';

import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:provider/provider.dart';

import 'package:fouryoupet/models/user/user_manager.dart';

import '../../common/empty_card.dart';
import '../../models/page_manager.dart';
import 'package:fouryoupet/common/app_network_image.dart';

class CompanyUserScreen extends StatefulWidget {
  const CompanyUserScreen(this.companyid);

  final String? companyid;

  @override
  State<CompanyUserScreen> createState() => _CompanyUserScreenState();
}

class _CompanyUserScreenState extends State<CompanyUserScreen> {
  Company? _company;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await context
          .read<CompanyManager>()
          .findCompanyByID2(widget.companyid);
      if (mounted) {
        setState(() => _company = result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 111, 0),
        centerTitle: true,
        title: Text('Dados da Empresa', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          Consumer2<UserManager, CompanyManager>(
            builder: (_, userManager, companyManager, __) {
              companyManager.company = _company;
              if (userManager.adminEnabled) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/editcompany', arguments: _company);
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.add_business),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/editcompany', arguments: _company);
                  },
                );
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
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer<CompanyManager>(
        builder: (_, companyManager, __) {
          var company = companyManager.findCompanyByID(widget.companyid);
          if (company == null) {
            return EmptyCard(
                title: 'Sem empresa cadastrada ou empresa inativa',
                iconData: Icons.business_center);
          } else {
            return ListView(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: AppNetworkImage(imageUrl: company.images!.first, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Nome',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        company.name ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 8)),
                      Text(
                        'CNPJ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        company.cnpj ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 8)),
                      Text(
                        'E-mail: ${company.email}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Fone: ${company.phone}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Prazo para entrega: ${company.prazoentrega}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (company.address != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Endereço',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${company.address!.city!} - ${company.address!.state!}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${company.address!.street!}  -  ${company.address!.number} ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${company.address!.complement != null ? company.address!.complement : ''}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Bairro: ${company.address!.district!}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'CEP: ${company.address!.zipCode}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
