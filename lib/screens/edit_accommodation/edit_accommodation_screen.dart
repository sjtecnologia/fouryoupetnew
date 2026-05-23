import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouryoupet/helpers/styles/text_styles.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';
import 'package:fouryoupet/models/accommodation/accommodation_manager.dart';
import 'package:fouryoupet/screens/edit_accommodation/components/dropdown.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/page_manager.dart';

// ignore: must_be_immutable
class EditAccommodationScreen extends StatefulWidget {
  EditAccommodationScreen(Accommodation? p)
      : editing = p != null,
        accommodation = p != null ? p.clone() : Accommodation();

  final Accommodation accommodation;
  final bool editing;

  @override
  State<EditAccommodationScreen> createState() =>
      _EditAccommodationScreenState();
}

class _EditAccommodationScreenState extends State<EditAccommodationScreen> {
  final formatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);

  var value = false;

  //var _visible = false;
  final TextEditingController _namecontroll = TextEditingController();

  final TextEditingController _description = TextEditingController();

  final TextEditingController _qtdatd = TextEditingController();

  final TextEditingController _price = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _namecontroll.dispose();
    _description.dispose();
    _qtdatd.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider.value(
      value: widget.accommodation,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            widget.editing ? 'Editar Hospedagem' : 'Cadastrar Vaga Hotelzinho',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            if (widget.editing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmar'),
                        content: Text(
                          'Confirmar a exclusão da imagem',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancelar',
                              style: context.textStyles.textBold
                                  .copyWith(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context
                                  .read<AccommodationManager>()
                                  .delete(widget.accommodation);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Confirmar',
                              style: context.textStyles.textBold,
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            IconButton(
              onPressed: () {
                context.read<PageManager>().setPage(0);
                // Se necessário, feche telas abertas
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Icon(Icons.home),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              // if (service != null) ImagesForm(service),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // SizedBox(
                    //   width: 50,
                    // ),
                    DropDown(widget.accommodation),
                    TextFormField(
                      initialValue:
                          widget.editing ? widget.accommodation.name : null,
                      controller: !widget.editing ? _namecontroll : null,
                      decoration: const InputDecoration(
                        label: Text('Título'),
                        hintText: 'Título',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      validator: (name) {
                        if (name!.length < 6) {
                          return 'Título muito curto';
                        }
                        return null;
                      },
                      onSaved: (name) => widget.accommodation.name = name,
                    ),

                    TextFormField(
                      initialValue: widget.editing
                          ? widget.accommodation.description
                          : null,
                      controller: !widget.editing ? _description : null,
                      decoration: const InputDecoration(
                        label: Text('Descrição'),
                        hintText: 'Descrição',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      validator: (description) {
                        if (description!.length < 10) {
                          return 'Descrição muito curta';
                        }
                        return null;
                      },
                      onSaved: (description) =>
                          widget.accommodation.description = description,
                    ),
                    // const SizedBox(
                    //   height: 20,
                    // ),

                    TextFormField(
                      initialValue: widget.editing
                          ? widget.accommodation.qtdatd.toString()
                          : null,
                      controller: !widget.editing ? _qtdatd : null,

                      keyboardType: TextInputType.number,
                      //initialValue: service.qtdatd.toString(),
                      textAlign: TextAlign.start,
                      decoration: const InputDecoration(
                        // labelStyle: TextStyle(color: Colors.grey),
                        label: Text('Atendimentos simultâneos'),
                        hintText: 'Atendimentos simultâneos',
                        border: InputBorder.none,
                      ),

                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      validator: (qtdatd) {
                        if (int.tryParse(qtdatd!) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                      onSaved: (qtdatd) =>
                          widget.accommodation.qtdatd = int.tryParse(qtdatd!),
                    ),
                    TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                      initialValue: widget.editing
                          ? 'R\$ ${formatter.format(widget.accommodation.price)}'
                          : null,
                      controller: !widget.editing ? _price : null,
                      decoration: const InputDecoration(
                        label: Text('Preço'),
                        hintText: 'Preço',
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (price) {
                        if (num.tryParse(price!) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                      onSaved: (price) {
                        price = price!.substring(2);
                        price = price.replaceAll(',', '.');
                        //price = price.replaceAll(' ', '');
                        widget.accommodation.price = num.tryParse(price);
                      },
                    ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),

                    Consumer<Accommodation>(
                      builder: (_, accommodation, __) {
                        return SizedBox(
                          height: 44,
                          // ignore: deprecated_member_use
                          child: ElevatedButton(
                            onPressed: !accommodation.loading
                                ? () async {
                                    accommodation.companyID = context
                                        .read<AccommodationManager>()
                                        .user!
                                        .companyID;
                                    //if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    await accommodation.save();
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.success(
                                        message: "Salvo com sucesso",
                                      ),
                                    );
                                    context
                                        .read<AccommodationManager>()
                                        .update(accommodation);
                                    Navigator.of(context).pop();
                                  }
                                //}
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  Theme.of(context).primaryColor.withAlpha(100),
                            ),
                            child: accommodation.loading
                                ? const CircularProgressIndicator.adaptive(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  )
                                : const Text(
                                    'Salvar',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      debugPrint('formatEditUpdate: baseOffset is 0');
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: "pt_Br");

    String newText = formatter.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
