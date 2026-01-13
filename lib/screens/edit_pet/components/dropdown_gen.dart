import 'package:flutter/material.dart';

import '../../../models/pet/pet.dart';

class DropDownGen extends StatefulWidget {
  DropDownGen(this.pet);

  final Pet pet;

  @override
  _DropDownGenState createState() => _DropDownGenState(pet);
}

class _DropDownGenState extends State<DropDownGen> {
  _DropDownGenState(this.pet);
  final Pet pet;
  String nomeGenero = "";
  String pos = "1";
  var _generos = [
    'Selecionar',
    'Macho',
    'Fêmea',
  ];
  String? _itemSelecionado = 'Selecionar';

  @override
  Widget build(BuildContext context) {
    if (pet.genero_id != null) {
      switch (pet.genero_id.toString()) {
        case '1':
          {
            _itemSelecionado = 'Macho';
          }
          break;
        case '2':
          {
            _itemSelecionado = 'Fêmea';
          }
          break;

        default:
          {
            _itemSelecionado = 'Selecionar';
          }
          break;
      }
    }
    return criaDropDownButton(pet);
  }

  criaDropDownButton(Pet pet) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Selecione o Gênero"),
          DropdownButton<String>(
              items: _generos.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem),
                );
              }).toList(),
              onChanged: (String? novoItemSelecionado) {
                _dropDownItemSelected(novoItemSelecionado);
                setState(() {
                  this._itemSelecionado = novoItemSelecionado;
                  switch (this._itemSelecionado) {
                    case 'Macho':
                      {
                        pet.genero_id = "1";
                      }
                      break;
                    case 'Fêmea':
                      {
                        pet.genero_id = "2";
                      }
                      break;

                    default:
                      {
                        pet.genero_id = "0";
                      }
                      break;
                  }
                });
              },
              value: _itemSelecionado),
        ],
      ),
    );
  }

  void _dropDownItemSelected(String? novoItem) {
    setState(() {
      this._itemSelecionado = novoItem;
    });
  }
}
