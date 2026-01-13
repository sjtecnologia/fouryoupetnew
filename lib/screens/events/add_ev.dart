import 'dart:developer';
import 'dart:math' as mat;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/couponcodes/couponcode_manager.dart';

import 'package:fouryoupet/models/event/event_firestore_service.dart';
import 'package:fouryoupet/models/notificatificacao/notifi.dart';
import 'package:fouryoupet/models/notificatificacao/notifications_manager.dart';

import 'package:fouryoupet/models/service/service_manager.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import 'package:fouryoupet/screens/events/components/button_hours_free.dart';
import 'package:fouryoupet/screens/events/data/services/event_provider.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../helpers/localnotification.dart';
import '../../helpers/send_email.dart';
import '../../models/event/event.dart';
import '../../models/service/service.dart';

class AddEv extends StatefulWidget {
  final DateTime? selectedDate;
  final AppEvent? event;
  final String? company;
  final int? homeclic;
  final Service? service;

  const AddEv({
    super.key,
    this.selectedDate,
    this.event,
    this.company,
    this.homeclic,
    this.service,
  });

  @override
  _AddEvState createState() => _AddEvState();
}

List<String> tm = [];
List<String> cp = [];

class _AddEvState extends State<AddEv> {
  TextEditingController dateController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponField = false;
  // Adicione esta flag para controlar o estado de "aplicando cupom"
  bool _isApplyingCoupon = false;
  @override
  void initState() {
    _couponController.clear();
    context.read<CouponCodeManager>().removeCoupon();
    context.read<ServiceManager>().updateService(widget.service as Service);
    tm = context.read<ServiceManager>().ghfree;

    cp = context
        .read<CompanyManager>()
        .findCompanyByID(widget.service!.companyID)!
        .daysoff!;

    super.initState();
  }

  final selectedIndexNotifier = ValueNotifier<int?>(null);
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void dispose() {
    _couponController.dispose();
    dateController.dispose();
    selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couponManager = context.watch<CouponCodeManager>();
    
    

    final discountAmount = couponManager.getDiscountAmount((widget.service!.basePrice!.toDouble())
        .toDouble()); // O desconto deve ser calculado sobre o total ou subtotal? Ajustei para (subtotal + entrega)
    
    var som;
    var somios;
    switch (widget.service!.categoryid) {
      case '1':
        {
          som = 'notification3';
          somios = 'notification3.aiff';
        }
        break;

      case '2':
        {
          som = 'notification1';
          somios = 'notification1.aiff';
        }
        break;
      case '4':
        {
          som = 'notification2';
          somios = 'notification2.aiff';
        }
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Agendamentos', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [],
      ),
      body: FormBuilder(
        key: _formKey,
        // SingleChildScrollView EXTERNO para rolar o FORMULÁRIO INTEIRO
        child: SingleChildScrollView(
          child: Column(
            // MODIFICADO: mainAxisSize.min para que a Column ocupe apenas o espaço necessário
            mainAxisSize: MainAxisSize.min,
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
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  hintText: 'Inserir Observação',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.short_text,
                    color: Colors.white,
                  ),
                ),
              ),
              Divider(),
              FormBuilderDateTimePicker(
                firstDate: DateTime.now(),
                initialDate: DateTime.now(),
                selectableDayPredicate: (DateTime val) {
                  List<int> daysoff = [];
                  String day;
                  for (int i = 0; i < cp.length; i++) {
                    if (cp[i].length >= 2) {
                      day = cp[i].substring(0, 2);
                      day = day.trim();
                    } else {
                      day = cp[i].substring(0, 1);
                      day = day.trim();
                    }

                    if (day.isNotEmpty) daysoff.add(int.parse(day));
                  }
                  if (daysoff.contains(val.weekday)) {
                    return false;
                  } else {
                    return true;
                  }
                },
                name: 'event_date',
                style: TextStyle(color: Colors.white),
                controller: dateController,
                initialValue: (DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    tm.length > 0 ? int.parse(tm[0].substring(0, 2)) : 0,
                    tm.length > 0 ? int.parse(tm[0].substring(3)) : 0,
                    0)),
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
                  context.read<ServiceManager>().updateService(widget.service!);
                  tm = context.read<ServiceManager>().ghfree;

                  setState(() {});
                  //dtNow = dtpar;
                },
              ),
              Divider(),
              // Este é o campo que dispara o problema
              //CouponField(cartTotal: widget.service!.basePrice!.toDouble()),
              _buildCouponSection(
                  context.read<CouponCodeManager>(),
                  widget.service!.basePrice!.toDouble()),
              // Desconto (se aplicado)
            if (couponManager.hasCouponApplied) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Desconto (${couponManager.appliedCoupon!.code})',
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text(
                    '- R\$ ${discountAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
              Divider(),
              if (tm.length > 0)
                Text(
                  'Horários Disponíveis',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              if (tm.length <= 0)
                Text(
                  'Sem Horários Disponíveis para este dia!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              Padding(padding: EdgeInsets.all(8)),
              if (tm.length > 0)
                // REMOVIDO: O SingleChildScrollView interno.
                // A rolagem será tratada pelo SingleChildScrollView externo.
                ValueListenableBuilder<int?>(
                  valueListenable: selectedIndexNotifier,
                  builder: (_, selectedIndex, __) {
                    if (selectedIndex == null) selectedIndex = 1;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 1; i <= tm.length; i++)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 30, // Altura definida para cada botão
                              width: MediaQuery.of(context).size.width,
                              child: ButtonHoursFree(
                                text: '${tm[i - 1]} h',
                                isFavorite: selectedIndex == i,
                                onPressed: () {
                                  int h1 =
                                      int.parse(tm[i - 1].substring(0, 2));
                                  int m1 = int.parse(tm[i - 1].substring(3));
                                  DateTime tst = _formKey
                                      .currentState?.fields.values.last.value;
                                  tst = DateTime(tst.year, tst.month, tst.day,
                                      h1, m1, 0);
                                  _formKey.currentState?.fields.values
                                      .elementAt(2)
                                      .didChange(tst);
                                  selectedIndex == i
                                      ? selectedIndexNotifier.value = null
                                      : selectedIndexNotifier.value = i;
                                },
                              ),
                            ),
                          ),
                        Consumer<EventProvider>(
                            builder: (_, eventManager, __) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 38, left: 38, bottom: 16),
                              child: Visibility(
                                visible: tm.length > 0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () async {
                                    //save event
                                    bool validated =
                                        _formKey.currentState!.validate();
                                    String cpid = '';
                                    if (widget.event == null) {
                                      cpid = widget.company!;
                                    } else {
                                      cpid = widget.event!.companyID!;
                                    }
                                    var testedt = _formKey
                                        .currentState?.fields.values
                                        .elementAt(2)
                                        .value;

                                    if (validated && testedt != null) {
                                      showTopSnackBar(
                                        Overlay.of(context),
                                        CustomSnackBar.success(
                                          message: "Salvo com sucesso",
                                        ),
                                      );
                                      // ignore: unused_local_variable
                                      List<AppEvent> vago;

                                      final data = Map<String, dynamic>.from(
                                          _formKey.currentState!.instantValue);

                                      // var dt = data['event_date'] as DateTime;
                                      var dt = _formKey
                                          .currentState?.fields.values
                                          .elementAt(2)
                                          .value;

                                      var dtf =
                                          DateTime(dt.year, dt.month, dt.day);
                                      var tp = widget.service!.type;
                                      if (widget.event == null) {
                                        vago = await eventManager.loadAllAppEvent(tp, dtf, cpid);
                                      } else {
                                        vago = await eventManager.loadAllAppEvent(tp, dtf, cpid);
                                      }

                                      data['event_date'] = dt;

                                      if (widget.event == null) {
                                        data['userID'] = context
                                            .read<UserManager>()
                                            .userapp!
                                            .id;
                                        data['companyID'] = widget.company!;

                                        data['categoryID'] =
                                            widget.service!.categoryid;

                                        data['type'] = widget.service!.type;
                                        data['serviceid'] = widget.service!.id;
                                        data['price'] = context
                                            .read<ServiceManager>()
                                            .findServiceByID(widget.service!.id)
                                            .basePrice;
                                        data['discount'] = discountAmount;
                                        data['couponCode'] = couponManager.hasCouponApplied ? couponManager.appliedCoupon!.code : null;
                                        data['status'] = 0;
                                        
                                        await eventDBS.create(data);
                                        await eventManager.checkout(
                                          orderId: null,
                                          userId: context
                                              .read<UserManager>()
                                              .userapp!
                                              .id,
                                          couponManager: couponManager
                                              .hasCouponApplied
                                              ? couponManager
                                              : null,
                                        );
                                      } else {
                                        await eventDBS.updateData(
                                            widget.event!.id!, data);
                                      }

                                      if (widget.service!.type == false) {
                                        notificacut(som, somios, dt);
                                      } else {
                                        notificavet(som, somios, dt);
                                      }

                                      sendemail(
                                          context,
                                          widget.service!.type!,
                                          widget.company!,
                                          som,
                                          dt);
                                      Navigator.of(context)
                                          .pushNamed('/myevents');
                                    } else {
                                      showTopSnackBar(
                                        Overlay.of(context),
                                        CustomSnackBar.error(
                                          message:
                                              "Favor selecionar um horário na lista abaixo",
                                        ),
                                      );
                                    }
                                  },
                                  child: Text('Salvar'),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              if (tm.length <= 0)
                Container(
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.timer_off,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void sendemail(
      BuildContext context, bool type, String companyID, som, somios) {
    if (type == false) {
      String? emailcompany =
          context.read<CompanyManager>().findCompanyByID(companyID)?.email;
      String? namecompany =
          context.read<CompanyManager>().findCompanyByID(companyID)?.name;
      String? subject = 'Novo Agendamento de Cuidados';
      String? message = 'Novo Agendamento de Cuidados recebido no App 4YouPet';
      try {
        sendEmail(
            name: namecompany!.toUpperCase(),
            email: emailcompany!,
            subject: subject,
            message: message);
      } on Exception catch (e, s) {
        log('Erro ao enviar email', error: e, stackTrace: s);
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Erro ao enviar email de notificação do Agendamento",
          ),
        );
      }
    } else {
      String? emailcompany =
          context.read<CompanyManager>().findCompanyByID(companyID)?.email;
      String? namecompany =
          context.read<CompanyManager>().findCompanyByID(companyID)?.name;
      String? subject = 'Novo Agendamento Veterinário';
      String? message = 'Novo Agendamento Veterinário recebido no App 4YouPet';
      try {
        sendEmail(
            name: namecompany!.toUpperCase(),
            email: emailcompany!,
            subject: subject,
            message: message);
      } on Exception catch (e, s) {
        log('Erro ao enviar email', error: e, stackTrace: s);
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Erro ao enviar email de notificação do Agendamento",
          ),
        );
      }
    }
  }

  Future<void> saveNotifications(DateTime? datahora, int tipo) async {
    Notifi notifi = Notifi();
    String dtmonth;
    String dtday;
    if (datahora?.month.toString().length == 1) {
      dtmonth = '0' + datahora!.month.toString();
    } else {
      dtmonth = datahora!.month.toString();
    }
    if (datahora.day.toString().length == 1) {
      dtday = '0' + datahora.day.toString();
    } else {
      dtday = datahora.day.toString();
    }

    notifi.image = null;
    notifi.lido = false;
    if (tipo == 1) {
      notifi.notificationBody =
          'Olá, não esqueça da agendamento dos cuidados de seu pet (banho, tosa e etc) ' +
              ' dia: ' +
              dtday +
              '/' +
              dtmonth +
              '/' +
              datahora.year.toString() +
              ' às ' +
              datahora.hour.toString() +
              ':' +
              datahora.minute.toString().padRight(  2, '0');
    } else {
      notifi.notificationBody =
          'Olá, não esqueça da agendamento veterinário de seu pet ' +
              ' dia: ' +
              dtday +
              '/' +
              dtmonth +
              '/' +
              datahora.year.toString() +
              ' às ' +
              datahora.hour.toString() +
              ':' +
              datahora.minute.toString().padRight(  2, '0');
    }
    notifi.notificationDate = Timestamp.now();
    notifi.notificationTitle = 'Lembrete de Agendamento';
    notifi.type = 'ntf';
    if (mounted) await context.read<NotificationsManager>().setNotifi(notifi);
    if (mounted) await context.read<NotificationsManager>().stNotific();
  }

  void notificacut(som, somios, DateTime? datahora) {
    String dtmonth;
    String dtday;
    String minutos;
    if(datahora?.minute.toString().length ==1){
      minutos = datahora!.minute.toString() +'0' ; 
    }else{
      minutos = datahora!.minute.toString() ; 
    }

    if (datahora.month.toString().length == 1) {
      dtmonth = '0' + datahora.month.toString();
    } else {
      dtmonth = datahora.month.toString();
    }
    if (datahora.day.toString().length == 1) {
      dtday = '0' + datahora.day.toString();
    } else {
      dtday = datahora.day.toString();
    }
    int id = mat.Random().nextInt(50000);
    try {
      Localnotification.showNotificationscheduled(
        som: som,
        somios: somios,
        id: id,
        title: 'Lembrete de Agendamento',
        body:
            'Olá, não esqueça da agendamento dos cuidados de seu pet (banho, tosa e etc) ' +
                ' dia: ' +
                dtday +
                '/' +
                dtmonth +
                '/' +
                datahora.year.toString() +
                ' às ' +
                datahora.hour.toString() +
                ':' +
                minutos,//datahora.minute.toString().padRight(2, '0'),
        dateTime: datahora.subtract(const Duration(minutes: 10)),
      );
      saveNotifications(datahora, 1);
    } catch (e, s) {
      log('Erro ao agendar notificação', error: e, stackTrace: s);
    }
  }

  void notificavet(som, somios, DateTime? datahora) {
    String dtmonth;
    String dtday;
    String minutos;
    if(datahora?.minute.toString().length ==1){
      minutos = datahora!.minute.toString() +'0' ; 
    }else{
      minutos = datahora!.minute.toString() ; 
    }

    if (datahora.month.toString().length == 1) {
      dtmonth = '0' + datahora.month.toString();
    } else {
      dtmonth = datahora.month.toString();
    }
    if (datahora.day.toString().length == 1) {
      dtday = '0' + datahora.day.toString();
    } else {
      dtday = datahora.day.toString();
    }
    int id = mat.Random().nextInt(50000);
    try {
      Localnotification.showNotificationscheduled(
        som: som,
        somios: somios,
        id: id,
        title: 'Lembrete de Agendamento',
        body: 'Olá, não esqueça da agendamento veterinário de seu pet ' +
            ' dia: ' +
            dtday +
            '/' +
            dtmonth +
            '/' +
            datahora.year.toString() +
            ' às ' +
            datahora.hour.toString() +
            ':' +
            minutos,
            //datahora.minute.toString().padRight(2, '0'),
        dateTime: datahora.subtract(const Duration(minutes: 10)),
      );
      saveNotifications(datahora, 2);
    } catch (e, s) {
      log('Erro ao agendar notificação', error: e, stackTrace: s);
    }
  }
  Widget _buildCouponSection(
      CouponCodeManager couponManager, double currentTotalForCoupon) {
    return Column(
      children: [
        if (!couponManager.hasCouponApplied && !_showCouponField)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showCouponField = true;
              });
            },
            icon: const Icon(Icons.local_offer),
            label: const Text('Aplicar cupom de desconto'),
          ),
        if (_showCouponField && !couponManager.hasCouponApplied) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Digite o código do cupom',
                    border: const OutlineInputBorder(),
                    errorText: couponManager.errorMessage,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showCouponField = false;
                          _couponController.clear();
                        });
                        couponManager.clearState();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isApplyingCoupon ||
                        couponManager.isLoading // Use _isApplyingCoupon
                    ? null
                    : () => _applyCoupon(couponManager, currentTotalForCoupon),
                child: _isApplyingCoupon || couponManager.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Aplicar'),
              ),
            ],
          ),
        ],
        if (couponManager.hasCouponApplied) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cupom ${couponManager.appliedCoupon!.code} aplicado!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    couponManager.removeCoupon();
                    setState(() {
                      _showCouponField = false;
                      _couponController.clear();
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.green.shade600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _applyCoupon(
      CouponCodeManager couponManager, double currentTotalForCoupon) async {
    if (_couponController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um código de cupom')),
      );
      return;
    }

    // Obtenha o userId do UserManager
    final userManager = context.read<UserManager>();
    final userId = userManager.userapp?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para usar um cupom.')),
      );
      return;
    }

    setState(() {
      _isApplyingCoupon = true; // Define a flag antes de chamar a API
    });

    final success = await couponManager.applyCoupon(
      _couponController.text.trim(),
      currentTotalForCoupon,
      userId,
    );

    setState(() {
      _isApplyingCoupon = false; // Reseta a flag após a chamada da API
    });

    if (success) {
      setState(() {
        _showCouponField = false;
      });
      _couponController.clear();
    }
  }
}