import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/company/company.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen(this.company);

  final Company? company;

  @override
  Widget build(BuildContext context) {
    //final primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider.value(
      value: company,
      child: Scaffold(
        appBar: AppBar(
          title: Text(company!.name!),
          centerTitle: true,
          actions: <Widget>[
            Consumer<UserManager>(
              builder: (_, userManager, __) {
                if (userManager.adminEnabled) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                          '/edit_company',
                          arguments: company);
                    },
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(company!.images!.first),
              // child: Carousel(
              //   images: company!.images!.map((url) {
              //     return NetworkImage(url);
              //   }).toList(),
              //   dotSize: 4,
              //   dotSpacing: 15,
              //   dotBgColor: Colors.transparent,
              //   dotColor: primaryColor,
              //   autoplay: false,
              //   boxFit: BoxFit.contain,
              // ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    company!.name!,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Consumer2<UserManager, Company>(
                    builder: (_, userManager, company, __) {
                      return SizedBox(
                        height: 44,
                        // ignore: deprecated_member_use
                        child: ElevatedButton(
                          onPressed: company.selectedCompany != null
                              ? () {
                                  if (userManager.isLoggedIn) {
                                    Navigator.of(context).pushNamed('/category',
                                        arguments: company);
                                  } else {
                                    Navigator.of(context).pushNamed('/login');
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Theme.of(context).primaryColor.withAlpha(100),
                          ),
                          child: Text(
                            userManager.isLoggedIn
                                ? 'Selecionar o Petshop'
                                : 'Entre para Selecionar',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
