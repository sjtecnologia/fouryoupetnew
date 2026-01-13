import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/screens/address/components/address_card.dart';
import 'package:provider/provider.dart';

import '../../models/page_manager.dart';

class AddressAdd extends StatelessWidget {
  const AddressAdd({Key? key, required this.address}) : super(key: key);
  final Address? address;
  @override
  Widget build(BuildContext context) {
    bool adding = false;
    //int qtdaddress = 0;

    if (this.address?.zipCode != null) {
      //qtdaddress = context.read<UserManager>().userapp!.address!.length;
      adding = false;
    } else {
      adding = true;
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: !adding
            ? const Text('Editar Endereços',
                style: TextStyle(color: Colors.white))
            : const Text('Cadastrar Endereços',
                style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
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
        child: ListView(children: <Widget>[
          SizedBox(height: 16),
          AddressCard(
            adding: adding,
            address: this.address!,
          ),
        ]),
      ),
    );
  }
}
