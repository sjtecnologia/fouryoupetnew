import 'package:flutter/material.dart';
import 'package:fouryoupet/helpers/styles/text_styles.dart';
import 'package:fouryoupet/models/service/service.dart';
import 'package:fouryoupet/models/service/service_manager.dart';
import 'package:fouryoupet/screens/edit_service/components/dropdown.dart';
import 'package:fouryoupet/screens/edit_service/components/hours_form.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/page_manager.dart';

import 'components/checkbox.dart';

import 'components/sizes_form.dart';

// ignore: must_be_immutable
class EditServiceScreen extends StatefulWidget {
  EditServiceScreen(Service? p)
      : editing = p != null,
        service = p != null ? p.clone() : Service();

  final Service service;
  final bool editing;

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  var value = false;

  //var _visible = false;
  final TextEditingController _namecontroll = TextEditingController();

  final TextEditingController _description = TextEditingController();

  final TextEditingController _qtdatd = TextEditingController();

  final TextEditingController _hinit = TextEditingController();

  final TextEditingController _hend = TextEditingController();

  final TextEditingController _hminute = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _namecontroll.dispose();
    _description.dispose();
    _qtdatd.dispose();
    _hinit.dispose();
    _hend.dispose();
    _hminute.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider.value(
      value: widget.service,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(widget.editing ? 'Editar Serviço' : 'Cadastrar Serviço',
              style: TextStyle(color: Colors.white)),
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
                          'Confirmar a exclusão do serviço',
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
                                  .read<ServiceManager>()
                                  .delete(widget.service);
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
                    DropDown(widget.service),
                    MyCheckbox(widget.service),
                    TextFormField(
                      initialValue: widget.editing
                          ? widget.service.name?.toUpperCase()
                          : null,
                      controller: !widget.editing ? _namecontroll : null,
                      decoration: const InputDecoration(
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
                      onSaved: (name) =>
                          widget.service.name = name?.toUpperCase(),
                    ),

                    TextFormField(
                      initialValue: widget.editing
                          ? widget.service.description?.toUpperCase()
                          : null,
                      controller: !widget.editing ? _description : null,
                      decoration: const InputDecoration(
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
                      onSaved: (description) => widget.service.description =
                          description?.toUpperCase(),
                    ),
                    SizesForm(widget.service),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Atendimentos simultâneos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      initialValue: widget.editing
                          ? widget.service.qtdatd.toString()
                          : null,
                      controller: !widget.editing ? _qtdatd : null,

                      keyboardType: TextInputType.number,
                      //initialValue: service.qtdatd.toString(),
                      textAlign: TextAlign.start,
                      decoration: const InputDecoration(
                        // labelStyle: TextStyle(color: Colors.grey),
                        // label: Text('Atendimentos simultâneos'),
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
                          widget.service.qtdatd = int.tryParse(qtdatd!),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: widget.editing
                          ? widget.service.hinit.toString()
                          : null,
                      controller: !widget.editing ? _hinit : null,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.start,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.grey),
                        label: Text('Inicio do Atendimento'),
                        hintText: 'Inicio do Atendimento - (Hora)',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      validator: (hinit) {
                        if (int.tryParse(hinit!) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                      onSaved: (hinit) =>
                          widget.service.hinit = int.tryParse(hinit!),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: widget.editing
                          ? widget.service.hend.toString()
                          : null,
                      controller: !widget.editing ? _hend : null,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.start,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.grey),
                        label: Text('Fim do Atendimento'),
                        hintText: 'Final do Atendimento - (Hora)',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      validator: (hend) {
                        if (int.tryParse(hend!) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                      onSaved: (hend) =>
                          widget.service.hend = int.tryParse(hend!),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: widget.editing
                          ? widget.service.hminute.toString()
                          : null,
                      controller: !widget.editing ? _hminute : null,

                      keyboardType: TextInputType.number,
                      //initialValue: service.qtdatd.toString(),
                      textAlign: TextAlign.start,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: Colors.grey),
                        label: Text('Duração do Atendimento'),
                        hintText: 'Duração do Atendimento - (Minutos)',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                      validator: (hminute) {
                        if (int.tryParse(hminute!) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                      onSaved: (hminute) =>
                          widget.service.hminute = int.tryParse(hminute!),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: widget.service.hours!.isNotEmpty,
                      child: Text(
                        'Horários de Atendimento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Visibility(
                      visible: widget.service.hours!.isNotEmpty,
                      child: HoursForm(
                        service: widget.service,
                      ),
                    ),
                    Consumer<Service>(
                      builder: (_, service, __) {
                        return SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: !service.loading
                                ? () async {
                                    service.companyID = context
                                        .read<ServiceManager>()
                                        .user!
                                        .companyID;
                                    //if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    await service.save();
                                    context
                                        .read<ServiceManager>()
                                        .update(service);
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.success(
                                        message: "Salvo com sucesso",
                                      ),
                                    );
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
                            child: service.loading
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
