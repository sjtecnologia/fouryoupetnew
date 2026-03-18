import 'package:flutter/material.dart';

import 'package:fouryoupet/models/pet/pet_manager.dart';

import 'package:fouryoupet/screens/pet/vacinas/components/vacinas_list_tile.dart';

import 'package:provider/provider.dart';

import '../../../models/pet/pet.dart';
import '../../../models/pet/vacinas/vacinas.dart';

class VacinasScreen extends StatefulWidget {
  VacinasScreen({required this.pet});

  final Pet pet;

  @override
  State<VacinasScreen> createState() => _VacinasScreenState();
}

class _VacinasScreenState extends State<VacinasScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: const Text('Vacinas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[
          Consumer<PetManager>(
            builder: (_, petManager, __) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/addvacina',
                      arguments: <String, dynamic>{
                        'pet': widget.pet,
                        'vacina': Vacinas(),
                      });
                  //context.watch<PetManager>();
                },
              );
            },
          )
        ],
      ),
      body: Center(
        child: Container(
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
              if (widget.pet.vacinas != null) {
                return Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).padding.top +
                            kToolbarHeight),
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(widget.pet.images!.first),
                                radius: 50,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pet.name!.toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width * .045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.pet.petcat != null)
                                Text(
                                  widget.pet.petcat!.toUpperCase(),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            .035,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                widget.pet.breed!.toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width * .035,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.pet.color!.toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width * .035,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.pet.idadepet != null)
                                Text(
                                  widget.pet.idadepet!.toUpperCase() + ' Anos',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            .035,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: widget.pet.vacinas!.length,
                          itemBuilder: (_, index) {
                            return Container(
                              color: Colors.white,
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    children: [
                                      VacinaListTile(widget.pet, index),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          petManager.removeVacina(widget.pet,
                                              widget.pet.vacinas![index]);
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
                                              context, '/addvacina',
                                              arguments: <String, dynamic>{
                                                'pet': widget.pet,
                                                'vacina':
                                                    widget.pet.vacinas![index],
                                              });
                                          petManager.editing = false;
                                          context.read<PetManager>();
                                          setState(() {});
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
                          }),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
