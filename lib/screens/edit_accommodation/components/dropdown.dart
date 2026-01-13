import 'package:flutter/material.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';

class DropDown extends StatefulWidget {
  DropDown(this.accommodation);

  final Accommodation? accommodation;

  @override
  _DropDownState createState() => _DropDownState(accommodation!);
}

class _DropDownState extends State<DropDown> {
  _DropDownState(this.accommodation);
  final Accommodation? accommodation;
  String nomeCategoria = "";
  String pos = "1";
  var _categorias = [
    'Selecionar',
    'Cachorro',
    'Gato',
    'Peixe',
    'Passaro',
    'Roedor',
    'Réptil'
  ];
  String? _itemSelecionado = 'Selecionar';

  @override
  Widget build(BuildContext context) {
    if (accommodation?.categoryid != null) {
      switch (accommodation?.categoryid.toString()) {
        case '0':
          {
            _itemSelecionado = 'Selecionar';
          }
          break;
        case '1':
          {
            _itemSelecionado = 'Cachorro';
          }
          break;
        case '2':
          {
            _itemSelecionado = 'Gato';
          }
          break;
        case '3':
          {
            _itemSelecionado = 'Peixe';
          }
          break;
        case '4':
          {
            _itemSelecionado = 'Passaro';
          }
          break;
        case '5':
          {
            _itemSelecionado = 'Roedor';
          }
          break;
        case '6':
          {
            _itemSelecionado = 'Réptil';
          }
          break;
        default:
          {
            _itemSelecionado = 'Selecionar';
          }
          break;
      }
    }
    return criaDropDownButton(accommodation);
  }

  criaDropDownButton(Accommodation? accommodation) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Selecione a categoria"),
          DropdownButton<String>(
              items: _categorias.map((String dropDownStringItem) {
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
                    case 'Selecionar':
                      {
                        accommodation?.categoryid = "0";
                      }
                      break;
                    case 'Cachorro':
                      {
                        accommodation?.categoryid = "1";
                      }
                      break;
                    case 'Gato':
                      {
                        accommodation?.categoryid = "2";
                      }
                      break;
                    case 'Peixe':
                      {
                        accommodation?.categoryid = "3";
                      }
                      break;
                    case 'Passaro':
                      {
                        accommodation?.categoryid = "4";
                      }
                      break;
                    case 'Roedor':
                      {
                        accommodation?.categoryid = "5";
                      }
                      break;
                    case 'Réptil':
                      {
                        accommodation?.categoryid = "6";
                      }
                      break;
                    default:
                      {
                        accommodation?.categoryid = "0";
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
      if (novoItem == null) novoItem = 'Selecionar';
      this._itemSelecionado = novoItem;
    });
  }
}
