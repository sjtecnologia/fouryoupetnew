import 'package:flutter/material.dart';

class ServiceHours extends StatefulWidget {
  const ServiceHours({Key? key}) : super(key: key);

  @override
  _ServiceHoursState createState() => _ServiceHoursState();
}

class _ServiceHoursState extends State<ServiceHours> {
  @override
  Widget build(BuildContext context) {
    Map<String, bool> h = {};
    for (int i = 0; i < 24; i++) {
      h.addAll({i.toString(): false});
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: h.keys.map((String key) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: new CheckboxListTile(
            title: new Text(key),
            value: h[key],
            onChanged: (bool? value) {
              setState(() {
                h[key] = value!;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}
