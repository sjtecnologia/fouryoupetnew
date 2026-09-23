import 'package:flutter/material.dart';
import 'package:fouryoupet/common/custom_icon_button.dart';

import 'package:fouryoupet/models/product/item_size.dart';

class EditItemSize extends StatelessWidget {
  const EditItemSize(
      {Key? key, this.size, this.onRemove, this.onMoveUp, this.onMoveDown})
      : super(key: key);

  final ItemSize? size;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 30,
          child: TextFormField(
            initialValue: size!.name,
            maxLength: 20,
            decoration: const InputDecoration(
              labelText: 'Título',
              isDense: true,
            ),
            validator: (name) {
              if (name!.isEmpty) {
                return 'Inválido';
              }
              return null;
            },
            onChanged: (name) => size!.name = name,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Expanded(
          flex: 30,
          child: TextFormField(
            initialValue: size!.stock?.toString(),
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: 'Estoque',
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            validator: (stock) {
              if (int.tryParse(stock!) == null) {
                return 'Inválido';
              }
              return null;
            },
            onChanged: (stock) => size!.stock = int.tryParse(stock),
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Expanded(
          flex: 40,
          child: TextFormField(
              initialValue: size!.price?.toStringAsFixed(2),
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: 'Preço',
                isDense: true,
                prefixText: 'R\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (price) {
                if (price!.contains(','))
                  price = price.replaceAll(RegExp(r','), '.');
                if (num.tryParse(price) == null) {
                  return 'Inválido';
                }

                return null;
              },
              onSaved: (price) {
                if (price!.contains(','))
                  price = price.replaceAll(RegExp(r','), '.');
                size!.price = num.tryParse(price);
              }),
        ),
        CustomIconButton(
          iconData: Icons.remove,
          color: Colors.red,
          onTap: onRemove,
        ),
        CustomIconButton(
          iconData: Icons.arrow_drop_up,
          color: Colors.black,
          onTap: onMoveUp,
        ),
        CustomIconButton(
          iconData: Icons.arrow_drop_down,
          color: Colors.black,
          onTap: onMoveDown,
        ),
      ],
    );
  }
}
