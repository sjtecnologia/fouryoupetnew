// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fouryoupet/models/pet/pet_manager.dart';

import 'package:fouryoupet/models/pet/vacinas/vacinasaplic.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/pet/pet.dart';

class ApplicationsScreen extends StatefulWidget {
  ApplicationsScreen({Key? key, this.vacinasaplic, this.pet}) : super(key: key);

  final Vacinasaplic? vacinasaplic;
  final Pet? pet;

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController dtapliccontroller = TextEditingController();

  @override
  void dispose() {
    dtapliccontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.vacinasaplic!.aplicatednew = null;
    final primaryColor = Theme.of(context).primaryColor;
    final WidgetStateProperty<Color?> trackColor =
        WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        // Track color when the switch is selected.
        if (states.contains(WidgetState.selected)) {
          return Colors.green.shade100;
        }

        return null;
      },
    );
    final WidgetStateProperty<Color?> overlayColor =
        WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        // Material color when switch is selected.
        if (states.contains(WidgetState.selected)) {
          // ignore: deprecated_member_use
          return Colors.green.withOpacity(0.54);
        }
        // Material color when switch is disabled.
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade400;
        }
        // Otherwise return null to set default material color
        // for remaining states such as when the switch is
        // hovered, or focused.
        return null;
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Aplicações', style: TextStyle(color: Colors.white)),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                  initialValue: widget.vacinasaplic!.marca == null
                      ? ''
                      : widget.vacinasaplic!.marca,
                  decoration: const InputDecoration(
                    labelText: 'Marca da Vacina',
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    hintText: 'Marca da Vacina',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                  validator: (marca) {
                    if (marca!.length < 1) {
                      return 'Nome da marca muito curto';
                    }
                    return null;
                  },
                  onChanged: (marca) {
                    widget.vacinasaplic!.aplicatednew = true;
                    widget.vacinasaplic!.marca = marca;
                  }),
              TextFormField(
                  initialValue: widget.vacinasaplic!.lote == null
                      ? ''
                      : widget.vacinasaplic!.lote,
                  decoration: const InputDecoration(
                    labelText: 'Lote da Vacina',
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    hintText: 'Lote da Vacina',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                  validator: (lote) {
                    if (lote!.length < 1) {
                      return 'Lote muito curto';
                    }
                    return null;
                  },
                  onChanged: (lote) {
                    widget.vacinasaplic!.aplicatednew = true;
                    widget.vacinasaplic!.lote = lote;
                  }),
              Row(
                children: [
                  Text(
                    'Vacina aplicada?',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Switch(
                      value: widget.vacinasaplic!.aplicated as bool,
                      activeThumbColor: Colors.green,
                      hoverColor: Colors.white,
                      trackColor: trackColor,
                      overlayColor: overlayColor,
                      onChanged: (bool value) {
                        setState(() {
                          widget.vacinasaplic!.aplicatednew = false;
                          if (widget.vacinasaplic!.aplicatednew !=
                              widget.vacinasaplic!.aplicated)
                            widget.vacinasaplic!.aplicatednew = true;
                          widget.vacinasaplic!.aplicated = value;
                        });
                      }),
                ],
              ),
              if (widget.vacinasaplic!.aplicated == true ||
                  widget.vacinasaplic!.aplicatednew == true)
                Row(
                  children: [
                    Text(
                      'Cadastrar o reforço?',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Switch(
                        value: widget.vacinasaplic!.incnewaplic,
                        activeThumbColor: Colors.green,
                        hoverColor: Colors.white,
                        trackColor: trackColor,
                        overlayColor: overlayColor,
                        onChanged: (bool value) {
                          setState(() {
                            widget.vacinasaplic!.incnewaplic = false;
                            if (widget.vacinasaplic!.incnewaplic !=
                                widget.vacinasaplic!.incnewaplic)
                              widget.vacinasaplic!.incnewaplic = true;
                            widget.vacinasaplic!.incnewaplic = value;
                          });
                        }),
                  ],
                ),
              FormBuilderDateTimePicker(
                //firstDate: widget.vacinasaplic!.dataaplicacao,
                //alwaysUse24HourFormat: true,
                validator: (dtapli) {
                  if (dtapli == null) {
                    return 'Deve ser informada a data de aplicação';
                  }
                  return null;
                },
                name: 'DataAplic',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                initialValue: (widget.vacinasaplic!.dataaplicacao),
                fieldHintText: 'Data de Aplicação da Vacina',
                locale: Locale('pt', 'BR'),
                inputType: InputType.date,
                format: DateFormat('dd/MM/yyyy'),
                fieldLabelText: 'Data de Aplicação da Vacina',
                decoration: InputDecoration(
                  label: Text(
                    'Data de Aplicação da Vacina',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.calendar_today_sharp,
                    color: Colors.white,
                  ),
                ),
                onChanged: (dtaplic) {
                  widget.vacinasaplic!.aplicatednew = true;
                  widget.vacinasaplic!.dtaplicnews = null;
                  if (widget.vacinasaplic!.dataaplicacao != dtaplic)
                    widget.vacinasaplic!.dtaplicnews = dtaplic;
                  widget.vacinasaplic!.dataaplicacao = dtaplic;
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Theme.of(context).primaryColor.withAlpha(100),
                ),
                onPressed: () async {
                  context.read<PetManager>().setVacinas(widget.pet!);
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text('Salvar Vacinação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
