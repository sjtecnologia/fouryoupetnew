import 'package:flutter/material.dart';

import '../../../models/pet/pet.dart';

class DropDownCategory extends StatefulWidget {
  DropDownCategory(this.pet);

  final Pet pet;

  @override
  _DropDownCategoryState createState() => _DropDownCategoryState(pet);
}

class _DropDownCategoryState extends State<DropDownCategory> {
  _DropDownCategoryState(this.pet);
  final Pet pet;
  String nomeCategoria = "";
  String pos = "1";
  var _categorias = [
    'Selecionar',
    'Cachorro',
    'Gato',
    'Peixe',
    'Pássaro',
    'Roedor',
    'Réptil'
  ];
  String? _itemSelecionado = 'Selecionar';

  @override
  Widget build(BuildContext context) {
    if (pet.category_id != null) {
      switch (pet.category_id.toString()) {
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
            _itemSelecionado = 'Pássaro';
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
    return criaDropDownButton(pet);
  }

  criaDropDownButton(Pet pet) {
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
                    case 'Cachorro':
                      {
                        pet.category_id = "1";
                      }
                      break;
                    case 'Gato':
                      {
                        pet.category_id = "2";
                      }
                      break;
                    case 'Peixe':
                      {
                        pet.category_id = "3";
                      }
                      break;
                    case 'Pássaro':
                      {
                        pet.category_id = "4";
                      }
                      break;
                    case 'Roedor':
                      {
                        pet.category_id = "5";
                      }
                      break;
                    case 'Réptil':
                      {
                        pet.category_id = "6";
                      }
                      break;
                    default:
                      {
                        pet.category_id = "0";
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
