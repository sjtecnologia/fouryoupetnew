import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pesos/pesos.dart';
import 'package:fouryoupet/models/pet/pet_manager.dart';
import 'package:fouryoupet/screens/pet/pesos/components/pesos_list_tile.dart';

import 'package:provider/provider.dart';

import '../../../models/page_manager.dart';
import '../../../models/pet/pet.dart';

// ignore: must_be_immutable
class PesoScreen extends StatefulWidget {
  PesoScreen({required this.pet});

  final Pet pet;

  @override
  State<PesoScreen> createState() => _PesoScreenState();
}

class _PesoScreenState extends State<PesoScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Pesos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              // Se necessário, feche telas abertas
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
          Consumer<PetManager>(
            builder: (_, petManager, __) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/addpeso',
                      arguments: <String, dynamic>{
                        'pet': widget.pet,
                        'pesos': Pesos(),
                      });
                  context.watch<PetManager>();
                },
              );
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
        child: Consumer<PetManager>(
          builder: (_, petManager, __) {
            if (petManager.loading) {
              return Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                ),
              );
            }
            if (widget.pet.pesos != null) {
              return ListView.builder(
                  itemCount: widget.pet.pesos!.length,
                  itemBuilder: (_, index) {
                    return Card(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              PesoListTile(widget.pet.pesos![index]),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  petManager.removePeso(
                                      widget.pet, widget.pet.pesos![index]);
                                },
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  petManager.editing = true;

                                  await Navigator.pushNamed(context, '/addpeso',
                                      arguments: <String, dynamic>{
                                        'pet': widget.pet,
                                        'pesos': widget.pet.pesos![index],
                                      });

                                  petManager.editing = false;
                                  await context.watch<PetManager>();
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
