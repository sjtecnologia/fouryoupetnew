// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:graphic/graphic.dart';

import 'package:intl/intl.dart';

import '../../../models/pet/pesos/pesos.dart';
import '../../../models/pet/pet.dart';

class PetListTile extends StatelessWidget {
  const PetListTile(this.pet);

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    var pesospet = pet.pesos;

    late Mark<Shape> chartMark;

    // --- Início da Modificação: Controle do TimeScale ---
    TimeScale timeScale;
    if (pesospet != null && pesospet.length == 1) {
      // Se houver apenas um registro de peso, definimos um intervalo de 5 dias
      // em torno da data do peso (1 dia antes e 3 dias depois).
      final singleDate = pesospet.first.datapeso as DateTime;
      final minDate =
          singleDate.subtract(const Duration(days: 1)); // Ex: 19/05/2025
      final maxDate = singleDate.add(const Duration(days: 3)); // Ex: 23/05/2025

      timeScale = TimeScale(
        formatter: (date) => DateFormat('dd/MM/yyyy').format(date),
        min: minDate,
        max: maxDate,
        // Opcional: Você pode tentar descomentar a linha abaixo se o eixo ainda
        // não mostrar exatamente 5 rótulos de data. O 'graphic' geralmente
        // lida bem com a geração de ticks quando min/max são definidos.
        // tickCount: 5,
      );
    } else {
      // Para múltiplos registros ou nenhum, usamos o TimeScale padrão.
      timeScale = TimeScale(
        formatter: (date) => DateFormat('dd/MM/yyyy').format(date),
        tickCount: pesospet?.length,
      );
    }
    // --- Fim da Modificação ---

    if (pesospet != null && pesospet.length == 1) {
      chartMark = PointMark(
        size: SizeEncode(value: 10),
        shape: ShapeEncode(value: CircleShape()),
        color: ColorEncode(value: primaryColor),
      ) as Mark<Shape>;
    } else {
      chartMark = LineMark(
        shape: ShapeEncode(value: BasicLineShape()),
        selected: {
          'touchMove': {1},
        },
      ) as Mark<Shape>;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/edit_pet', arguments: pet);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: MediaQuery.of(context).size.height * .50,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  if (pet.images != null && pet.images!.isNotEmpty)
                    Container(
                      width: MediaQuery.of(context).size.width * .25,
                      child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 50,
                          backgroundImage: NetworkImage(
                            pet.images!.first,
                          ) //Image.network(pet.images!.first),
                          ),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        pet.name!.toUpperCase(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .045,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      if (pet.petcat != null)
                        Text(
                          pet.petcat!.toUpperCase(),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * .030,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      Text(
                        pet.breed!.toUpperCase(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .030,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'Nasc.:' + DateFormat('dd/MM/yyyy').format(pet.birth!),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .025,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      if (pet.idadepet != null)
                        Text(
                          pet.idadepet! + ' Anos',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * .025,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.of(context)
                                  .pushNamed('/vacinaspet', arguments: pet);
                            },
                            icon: Icon(
                              Icons.vaccines,
                              color: primaryColor,
                              size: MediaQuery.of(context).size.width * .050,
                            ),
                            label: Text(
                              'Vacinas',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * .030,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.of(context)
                                  .pushNamed('/prontuariospet', arguments: pet);
                            },
                            icon: Icon(
                              Icons.medical_services,
                              color: primaryColor,
                              size: MediaQuery.of(context).size.width * .045,
                            ),
                            label: Text(
                              'Prontuário',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * .030,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.of(context)
                                  .pushNamed('/pesospet', arguments: pet);
                            },
                            icon: Icon(
                              Icons.scale,
                              color: primaryColor,
                              size: MediaQuery.of(context).size.width * .050,
                            ),
                            label: Text(
                              'Pesos',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * .030,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * .90,
                  child: (pesospet == null || pesospet.isEmpty)
                      ? Center(
                          child: Text(
                            'Nenhum registro de peso disponível.',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * .030,
                              color: primaryColor,
                            ),
                          ),
                        )
                      : Chart<Pesos>(
                          padding: (size) => EdgeInsets.all(30),
                          data: pesospet,
                          variables: {
                            'Data': Variable(
                              accessor: (pesos) => pesos.datapeso as DateTime,
                              // --- Aqui usamos a TimeScale que definimos dinamicamente ---
                              scale: timeScale,
                            ),
                            'Peso': Variable(
                              accessor: (pesos) =>
                                  double.parse(pesos.peso ?? '0.0'),
                            ),
                          },
                          marks: [
                            chartMark,
                          ],
                          coord: RectCoord(color: const Color(0xFFf5f5f5)),
                          axes: [
                            Defaults.horizontalAxis,
                            Defaults.verticalAxis,
                          ],
                          selections: {
                            'touchMove': PointSelection(on: {
                              GestureType.scaleUpdate,
                              GestureType.tapDown,
                              GestureType.longPressMoveUpdate
                            }, dim: Dim.x),
                          },
                          tooltip: pesospet.length > 1
                              ? TooltipGuide(
                                  followPointer: [false, true],
                                  align: Alignment.topLeft,
                                  offset: const Offset(-20, -20),
                                  textStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            .030,
                                    color: primaryColor,
                                  ),
                                )
                              : null,
                          crosshair: pesospet.length > 1
                              ? CrosshairGuide(
                                  followPointer: [false, true],
                                )
                              : null,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
