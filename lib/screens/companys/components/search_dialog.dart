import 'package:flutter/material.dart';

class SearchDialog extends StatefulWidget {
  final String initialText;
  //final void Function(GlobalKey<FormFieldState<String>>) onKeyReady;
  const SearchDialog(this.initialText, {Key? key}) : super(key: key);

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _formKey = GlobalKey<FormState>(); // <-- Crie o GlobalKey aqui
  final _textFieldKey =
      GlobalKey<FormFieldState<String>>(); // <-- Crie o GlobalKey aqui
  final _focusNode = FocusNode(); // Crie um FocusNode
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textFieldKey.currentState?.mounted ?? false) {
        // Verifique se está montado
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Libere o FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 2,
          left: 4,
          right: 4,
          child: Card(
            child: Form(
              key: _formKey,
              child: TextFormField(
                key: _textFieldKey, // <-- Adicione a chave aqui
                initialValue: widget.initialText,
                textInputAction: TextInputAction.search,
                autofocus: false,
                focusNode: _focusNode,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
                onFieldSubmitted: (text) {
                  Navigator.of(context).pop(text);
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
