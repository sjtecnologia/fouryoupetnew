import 'package:flutter/material.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:intl/intl.dart';

class DropDown extends StatefulWidget {
  DropDown(this.cartproduct);

  final CartManager cartproduct;

  @override
  _DropDownState createState() => _DropDownState(cartproduct);
}

class _DropDownState extends State<DropDown> {
  final formatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
  @override
  void initState() {
    super.initState();
  }

  _DropDownState(this.cartproduct);
  final CartManager cartproduct;
  String formapagto = "";
  var _formapagto = [
    'Cartão Crédito',
    'Cartão Débito',
    'Dinheiro',
  ];
  String? _itemSelecionado = 'Cartão Crédito';

  @override
  Widget build(BuildContext context) {
    if (cartproduct.payId != null) {
      _itemSelecionado = cartproduct.payId.toString();
    }
    return criaDropDownButton(cartproduct);
  }

  criaDropDownButton(CartManager cartproduct) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Text("Forma de Pagamento:"),
              SizedBox(
                width: 10,
              ),
              DropdownButton<String>(
                icon: const Icon(Icons.payments_sharp),
                items: _formapagto.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                onChanged: (String? novoItemSelecionado) {
                  _dropDownItemSelected(novoItemSelecionado);
                  setState(() {
                    this._itemSelecionado = novoItemSelecionado;
                    cartproduct.payId = this._itemSelecionado.toString();
                    if (cartproduct.payId != "Dinheiro") {
                      cartproduct.trocopara = 0.00;
                    }
                  });
                },
                value: _itemSelecionado,
              ),
            ],
          ),
          Visibility(
            visible: cartproduct.payId == "Dinheiro",
            child: TextFormField(
              initialValue: formatter.format(cartproduct.trocopara ?? '0.00'),
              decoration: const InputDecoration(
                labelText: 'Troco para: ',
                isDense: true,
                prefixText: 'R\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (troco) {
                if (num.tryParse(troco!) == null) {
                  return 'Inválido';
                }
                if (cartproduct.payId == "Forma de Pagamento") {
                  return 'Inválido';
                }
                return null;
              },
              onChanged: (troco) => cartproduct.trocopara = num.tryParse(troco),
            ),
          ),
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
