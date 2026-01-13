import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pet.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/pet/pet_manager.dart';
import '../../../../models/pet/vacinas/vacinas.dart';
import '../applications/applications_screen.dart';

class VacinaListTile extends StatefulWidget {
  const VacinaListTile(this.pet, this.index);

  final Pet pet;
  final int index;

  @override
  State<VacinaListTile> createState() => _VacinaListTileState();
}

var cp = <Vacinas>[];

class _VacinaListTileState extends State<VacinaListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final f = new DateFormat('dd/MM/yyyy');
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(width: 4, color: primaryColor)),
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)]),
      height: MediaQuery.of(context).size.height * .195,
      width: MediaQuery.of(context).size.width * .80,
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            widget.pet.vacinas![widget.index].name!.toUpperCase(),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * .045,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Container(
            height: 90,
            //width: 200,
            child: ListView.builder(
              itemCount: widget.pet.vacinas![widget.index].aplic?.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 15, right: 15, top: 10),
                          //padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: widget.pet.vacinas![widget.index]
                                    .aplic![index].aplicated!
                                ? Colors.greenAccent
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApplicationsScreen(
                                    vacinasaplic: widget.pet
                                        .vacinas![widget.index].aplic![index],
                                    pet: widget.pet,
                                  ),
                                ),
                              );

                              context.read<PetManager>().setVacinas(widget.pet);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.vaccines,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (widget.pet.vacinas![widget.index].aplic!.length -
                                1 >
                            index)
                          Container(
                            height: 2,
                            width: 50,
                            color: primaryColor,
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            f.format(widget.pet.vacinas![widget.index]
                                .aplic![index].dataaplicacao as DateTime),
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        )
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
