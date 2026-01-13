import 'package:flutter/material.dart';
import 'package:fouryoupet/models/product/product.dart';

class DropDown extends StatefulWidget {
  DropDown(this.product);

  final Product product;

  @override
  _DropDownState createState() => _DropDownState(product);
}

class _DropDownState extends State<DropDown> {
  _DropDownState(this.product);
  final Product product;
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
    if (product.categoryid != null) {
      switch (product.categoryid.toString()) {
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
    return criaDropDownButton(product);
  }

  criaDropDownButton(Product product) {
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
                        product.categoryid = "1";
                      }
                      break;
                    case 'Gato':
                      {
                        product.categoryid = "2";
                      }
                      break;
                    case 'Peixe':
                      {
                        product.categoryid = "3";
                      }
                      break;
                    case 'Passaro':
                      {
                        product.categoryid = "4";
                      }
                      break;
                    case 'Roedor':
                      {
                        product.categoryid = "5";
                      }
                      break;
                    case 'Réptil':
                      {
                        product.categoryid = "6";
                      }
                      break;
                    default:
                      {
                        product.categoryid = "0";
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
