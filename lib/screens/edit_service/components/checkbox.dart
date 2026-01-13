import 'package:flutter/material.dart';
import 'package:fouryoupet/models/service/service.dart';

class MyCheckbox extends StatefulWidget {
  MyCheckbox(this.service);

  final Service? service;

  @override
  _MyCheckboxState createState() => _MyCheckboxState(service!);
}

class _MyCheckboxState extends State<MyCheckbox> {
  _MyCheckboxState(this.service);
  final Service service;

  //bool valuet = false;

  //set value(bool value) {}

  @override
  Widget build(BuildContext context) {
    return criaMyCheckboxButton(service);
  }

  criaMyCheckboxButton(Service service) {
    return Container(
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Color.fromARGB(255, 255, 111, 0),
            value: service.type ?? false,
            title: Text(
              'Veterinário',
              style: TextStyle(fontSize: 20),
            ),
            onChanged: (value) {
              setState(() {
                service.type = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
