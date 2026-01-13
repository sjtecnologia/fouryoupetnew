import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pet_manager.dart';
import 'package:fouryoupet/models/pet/prontuario/prontuarios.dart';
import 'package:fouryoupet/screens/pet/prontuario/components/prontuarios_list_tile.dart';

import 'package:provider/provider.dart';

import '../../../models/page_manager.dart';
import '../../../models/pet/pet.dart';

// ignore: must_be_immutable
class ProntuariosScreen extends StatefulWidget {
  ProntuariosScreen({required this.pet});

  final Pet pet;

  @override
  State<ProntuariosScreen> createState() => _ProntuariosScreenState();
}

class _ProntuariosScreenState extends State<ProntuariosScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Prontuários', style: TextStyle(color: Colors.white)),
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
                  await Navigator.pushNamed(context, '/addprontuario',
                      arguments: <String, dynamic>{
                        'pet': widget.pet,
                        'prontuario': Prontuarios(),
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
            if (widget.pet.prontuarios != null) {
              return ListView.builder(
                  itemCount: widget.pet.prontuarios!.length,
                  itemBuilder: (_, index) {
                    return Card(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              ProntuarioListTile(
                                  widget.pet.prontuarios![index]),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  petManager.removeProntuario(widget.pet,
                                      widget.pet.prontuarios![index]);
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

                                  await Navigator.pushNamed(
                                      context, '/addprontuario',
                                      arguments: <String, dynamic>{
                                        'pet': widget.pet,
                                        'prontuario':
                                            widget.pet.prontuarios![index],
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
