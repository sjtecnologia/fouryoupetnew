import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fouryoupet/common/loader.dart';

import 'package:fouryoupet/models/event/event.dart';
import 'package:fouryoupet/models/event/event_firestore_service.dart';
import 'package:fouryoupet/models/service/service.dart';
import 'package:fouryoupet/models/service/service_manager.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:validatorless/validatorless.dart';

import '../../helpers/send_email.dart';
import '../../models/company/company_manager.dart';
import '../../models/page_manager.dart';

class AddEventPage extends StatefulWidget {
  final DateTime? selectedDate;
  final AppEvent? event;
  final String? company;
  final int? homeclic;
  final Service? service;

  const AddEventPage(
      {Key? key,
      this.selectedDate,
      this.event,
      this.company,
      this.homeclic,
      this.service})
      : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    DateTime? dtNow;

    List<int> tm = [];

    if (widget.event != null) {
      dtNow = widget.event!.event_date;
    } else if (DateTime.now().weekday == 7) {
      dtNow = DateTime.now().add(Duration(days: 1));
    } else if (DateTime.now().weekday == 6) {
      dtNow = DateTime.now().add(Duration(days: 2));
    } else
      dtNow = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Agendamentos 1', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Loader.show();
                  //save event
                  bool validated = _formKey.currentState!.validate();
                  String cpid = '';
                  if (widget.event == null) {
                    cpid = widget.company!;
                  } else {
                    cpid = widget.event!.companyID!;
                  }
                  if (validated) {
                    _formKey.currentState!.save();
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.success(
                        message: "Salvo com sucesso",
                      ),
                    );
                    // ignore: unused_local_variable
                    List<AppEvent> vago;

                    final data =
                        Map<String, dynamic>.from(_formKey.currentState!.value);
                    var dt = data['event_date'] as DateTime;

                    var dtf = DateTime(dt.year, dt.month, dt.day);
                    var tp = widget.service!.type;
                    if (widget.event == null) {
                      vago = await eventDBS.getQueryList(args: [
                        QueryArgsV2(
                          "type",
                          isEqualTo: tp,
                        ),
                        QueryArgsV2(
                          "event_date",
                          isGreaterThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2(
                          "event_date",
                          isLessThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2("companyID", isEqualTo: cpid)
                      ]);
                    } else {
                      vago = await eventDBS.getQueryList(args: [
                        QueryArgsV2(
                          "type",
                          isEqualTo: tp,
                        ),
                        QueryArgsV2(
                          "event_date",
                          isGreaterThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2(
                          "event_date",
                          isLessThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2("companyID", isEqualTo: cpid)
                      ]);
                    }

                    data['event_date'] = dt;
                    //dtf; //(data['event_date'] as DateTime?);
                    if (widget.event == null) {
                      data['userID'] = context.read<UserManager>().userapp!.id;
                      data['companyID'] = widget.company!;

                      data['categoryID'] = widget.service!.categoryid;

                      data['type'] = widget.service!.type;
                      data['serviceid'] = widget.service!.id;
                      data['price'] = context
                          .read<ServiceManager>()
                          .findServiceByID(widget.service!.id)
                          .basePrice;
                      data['status'] = 'tasked';
                      await eventDBS.create(data);
                    } else {
                      //edit and update
                      await eventDBS.updateData(widget.event!.id!, data);
                    }

                    //Navigator.pop(context);
                    if (widget.service!.type == false) {
                      String? emailcompany = context
                          .read<CompanyManager>()
                          .findCompanyByID(widget.company!)!
                          .email;
                      String? namecompany = context
                          .read<CompanyManager>()
                          .findCompanyByID(widget.company!)
                          ?.name;
                      String? subject = 'Novo Agendamento de Cuidados';
                      String? message =
                          'Novo Agendamento de Cuidados recebido no App 4YouPet';
                      sendEmail(
                          name: namecompany!.toUpperCase(),
                          email: emailcompany!,
                          subject: subject,
                          message: message);
                    } else {
                      String? emailcompany = context
                          .read<CompanyManager>()
                          .findCompanyByID(widget.company!)
                          ?.email;
                      String? namecompany = context
                          .read<CompanyManager>()
                          .findCompanyByID(widget.company!)
                          ?.name;
                      String? subject = 'Novo Agendamento Veterinário';
                      String? message =
                          'Novo Agendamento Veterinário recebido no App 4YouPet';
                      sendEmail(
                          name: namecompany!.toUpperCase(),
                          email: emailcompany!,
                          subject: subject,
                          message: message);
                    }
                    Loader.hide();
                    context.read<PageManager>().setPage(0);
                    // Se necessário, feche telas abertas
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: Text('Salvar'),
              ),
            ),
          ),
        ],
      ),
      body: FormBuilder(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FormBuilderTextField(
                    name: 'title',
                    style: TextStyle(color: Colors.white),
                    initialValue: widget.event?.title ?? widget.service!.name,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Inserir Título',
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(left: 48.0),
                    ),
                  ),
                  Divider(),
                  FormBuilderTextField(
                    name: 'description',
                    style: TextStyle(color: Colors.white),
                    initialValue: widget.event?.description ?? '',
                    maxLines: 5,
                    validator: Validatorless.required(
                        'Obrigatório informar nome do pet e raça'),
                    decoration: InputDecoration(
                      label: Text('Nome do Pet - Raça - Porte - Observações'),
                      hintStyle: TextStyle(color: Colors.white),
                      hintText:
                          'Inserir Nome do Pet - Raça - Porte - Observação',
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.short_text,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Divider(),
                  FormBuilderDateTimePicker(
                    selectableDayPredicate: (DateTime val) {
                      if (val.weekday == 7 || val.weekday == 6) {
                        return false;
                      } else {
                        return true;
                      }
                    },
                    //alwaysUse24HourFormat: true,

                    name: 'event_date',
                    style: TextStyle(color: Colors.white),
                    initialValue: (dtNow),
                    fieldHintText: 'Inserir Data',
                    locale: Locale('pt', 'BR'),
                    inputType: InputType.date,
                    format: DateFormat('dd/MM/yyyy HH:mm'),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.calendar_today_sharp,
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (dtpar) {
                      context.read<ServiceManager>().updateDataEvent(dtpar);
                      context
                          .read<ServiceManager>()
                          .updateService(widget.service!);
                    },
                  ),
                  Divider(),
                  Text(
                    'Horários Disponíveis',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          addRepaintBoundaries: true,
                          itemCount:
                              context.read<ServiceManager>().hoursfree.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) =>
                              Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                child: Text(
                                  //'${time[index]} ${time[index] > 8 ? 'PM' : 'AM'}',
                                  '${context.read<ServiceManager>().hoursfree[index]}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  DateTime tst = _formKey
                                      .currentState?.fields.values.last.value;
                                  tst = DateTime(tst.year, tst.month, tst.day,
                                      tm[index], 0, 0);
                                  _formKey.currentState?.fields.values
                                      .elementAt(2)
                                      .didChange(tst);

                                  // print(_formKey.currentState?.fields.values
                                  //     .elementAt(2)
                                  //     .value);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
