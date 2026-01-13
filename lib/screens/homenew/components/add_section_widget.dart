import 'package:flutter/material.dart';
import 'package:fouryoupet/models/home_manager.dart';
import 'package:fouryoupet/models/section/section.dart';

class AddSectionWidget extends StatelessWidget {
  const AddSectionWidget(this.homeManager);

  final HomeManager homeManager;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: TextButton(
          onPressed: () {
            homeManager.addSection(Section(type: 'List', items: []));
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
          ),

          //textColor: Colors.white,
          child: const Text('Adicionar Lista'),
        )),
        Expanded(
            // ignore: deprecated_member_use
            child: TextButton(
          onPressed: () {
            homeManager.addSection(Section(type: 'Staggered', items: []));
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          child: const Text('Adicionar Grade'),
        )),
      ],
    );
  }
}
