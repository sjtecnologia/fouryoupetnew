import 'package:flutter/material.dart';

class StatusCompanyText extends StatelessWidget {
  const StatusCompanyText({
    Key? key,
    required this.abertura,
    required this.fechamento,
    required this.daysoff,
  }) : super(key: key);

  final String abertura;
  final String fechamento;
  final List<String> daysoff;

  @override
  Widget build(BuildContext context) {
    String status = 'Aberto';
    if (daysoff.contains(
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour,
        DateTime.now().minute,
        0,
        0,
        0,
      ).weekday,
    )) {
      status = 'Fechado';
    } else if (abertura != "" && fechamento != "") {
      if (DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, 0, 0, 0).compareTo(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(abertura.substring(0, 2)), int.parse(abertura.substring(3)), 0, 0, 0)) == 1 &&
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, 0, 0, 0)
                  .compareTo(DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      int.parse(fechamento.substring(0, 2)),
                      int.parse(fechamento.substring(3)),
                      0,
                      0,
                      0)) ==
              -1) {
        status = 'Aberto até às ${fechamento}';
      } else if (DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      DateTime.now().hour,
                      DateTime.now().minute,
                      0,
                      0,
                      0)
                  .compareTo(DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      int.parse(abertura.substring(0, 2)),
                      int.parse(abertura.substring(3)),
                      0,
                      0,
                      0)) ==
              -1 ||
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, 0, 0, 0)
                  .compareTo(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(fechamento.substring(0, 2)), int.parse(fechamento.substring(3)), 0, 0, 0)) ==
              1) {
        status = 'Fechado';
      }
    }

    return Text(
      status,
      style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black45),
    );
  }
}
