import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter.currency(
          decimalDigits: 2, locale: 'pt_BR', symbol: "");
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

  final _trocoEC = TextEditingController();

  @override
  void dispose() {
    _trocoEC.dispose();
    super.dispose();
  }

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
              // initialValue: _formatter.format(cartproduct.trocopara
              //     .toString()), //formatter.format(cartproduct.trocopara),
              //initialValue: _formatter.format(cartproduct.trocopara.toString()),
              controller: _trocoEC,
              inputFormatters: <TextInputFormatter>[_formatter],
              decoration: const InputDecoration(
                labelText: 'Troco para: ',
                isDense: true,
                prefixText: 'R\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (troco) {
                if (num.tryParse(troco!.replaceAll(r',', '.')) == null) {
                  return 'Inválido';
                }
                if (cartproduct.payId == "Forma de Pagamento") {
                  return 'Inválido';
                }
                return null;
              },
              onChanged: (troco) => cartproduct.trocopara =
                  num.parse(troco.replaceAll(r',', '.')),
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
