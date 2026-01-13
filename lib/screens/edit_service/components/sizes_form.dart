import 'package:flutter/material.dart';
import 'package:fouryoupet/helpers/custom_icon_button.dart';
import 'package:fouryoupet/models/service/item_size.dart';

import 'package:fouryoupet/models/service/service.dart';

import 'edit_item_size.dart';

class SizesForm extends StatelessWidget {
  const SizesForm(this.service);

  final Service service;

  @override
  Widget build(BuildContext context) {
    return FormField<List<ItemSize>>(
      initialValue: service.sizes,
      validator: (sizes) {
        if (sizes!.isEmpty) {
          return 'Insira um detalhe';
        }
        return null;
      },
      builder: (state) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Detalhes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                CustomIconButton(
                  iconData: Icons.add,
                  color: Colors.black,
                  onTap: () {
                    state.value!.add(ItemSize());
                    state.didChange(state.value);
                  },
                )
              ],
            ),
            Column(
              children: state.value!.map((size) {
                return EditItemSize(
                  key: ObjectKey(size),
                  size: size,
                  onRemove: () {
                    state.value!.remove(size);
                    state.didChange(state.value);
                  },
                  onMoveUp: size != state.value!.first
                      ? () {
                          final index = state.value!.indexOf(size);
                          state.value!.remove(size);
                          state.value!.insert(index - 1, size);
                          state.didChange(state.value);
                        }
                      : null,
                  onMoveDown: size != state.value!.last
                      ? () {
                          final index = state.value!.indexOf(size);
                          state.value!.remove(size);
                          state.value!.insert(index + 1, size);
                          state.didChange(state.value);
                        }
                      : null,
                );
              }).toList(),
            ),
            if (state.hasError)
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
