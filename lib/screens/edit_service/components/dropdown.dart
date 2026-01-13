import 'package:flutter/material.dart';
import 'package:fouryoupet/models/service/service.dart';

class DropDown extends StatefulWidget {
  DropDown(this.service);

  final Service? service;

  @override
  _DropDownState createState() => _DropDownState(service!);
}

class _DropDownState extends State<DropDown> {
  _DropDownState(this.service);
  final Service? service;
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
    if (service?.categoryid != null) {
      switch (service?.categoryid.toString()) {
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
    return criaDropDownButton(service);
  }

  criaDropDownButton(Service? service) {
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
                        service?.categoryid = "0";
                      }
                      break;
                    case 'Cachorro':
                      {
                        service?.categoryid = "1";
                      }
                      break;
                    case 'Gato':
                      {
                        service?.categoryid = "2";
                      }
                      break;
                    case 'Peixe':
                      {
                        service?.categoryid = "3";
                      }
                      break;
                    case 'Passaro':
                      {
                        service?.categoryid = "4";
                      }
                      break;
                    case 'Roedor':
                      {
                        service?.categoryid = "5";
                      }
                      break;
                    case 'Réptil':
                      {
                        service?.categoryid = "6";
                      }
                      break;
                    default:
                      {
                        service?.categoryid = "0";
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
