import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fouryoupet/common/loader.dart';
import 'package:fouryoupet/models/accommodation/accommodation_manager.dart';

import 'package:fouryoupet/models/hotel/hotel.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/accommodation/accommodation.dart';
import '../../models/hotel/hotel_firestore_service.dart';

class AddHotelPage extends StatefulWidget {
  final DateTime? selectedDate;
  final Hotel? hotel;
  final String? company;
  final int? homeclic;
  final Accommodation? accommodation;

  const AddHotelPage(
      {Key? key,
      this.selectedDate,
      this.hotel,
      this.company,
      this.homeclic,
      this.accommodation})
      : super(key: key);

  @override
  State<AddHotelPage> createState() => _AddHotelPageState();
}

class _AddHotelPageState extends State<AddHotelPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    DateTime? dtNow;

    //List<int> tm = [];

    if (widget.hotel != null) {
      dtNow = widget.hotel!.ini_date;
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
        title: Text('Hospedagem'),
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
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Loader.show();
                  //save event
                  bool validated = _formKey.currentState!.validate();
                  String cpid = '';
                  if (widget.hotel == null) {
                    cpid = widget.company!;
                  } else {
                    cpid = widget.hotel!.companyID!;
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
                    List<Hotel> vago;

                    final data =
                        Map<String, dynamic>.from(_formKey.currentState!.value);
                    var dt = data['ini_date'] as DateTime;

                    var dtf = DateTime(dt.year, dt.month, dt.day);
                    if (widget.hotel == null) {
                      vago = await hotelDBS.getQueryList(args: [
                        QueryArgsV2(
                          "ini_date",
                          isGreaterThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2(
                          "end_date",
                          isLessThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2("companyID", isEqualTo: cpid)
                      ]);
                    } else {
                      vago = await hotelDBS.getQueryList(args: [
                        QueryArgsV2(
                          "ini_date",
                          isGreaterThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2(
                          "end_date",
                          isLessThanOrEqualTo: (dtf),
                        ),
                        QueryArgsV2("companyID", isEqualTo: cpid)
                      ]);
                    }

                    data['ini_date'] = dt;
                    //dtf; //(data['event_date'] as DateTime?);
                    if (widget.hotel == null) {
                      data['userID'] = context.read<UserManager>().userapp!.id;
                      data['companyID'] = widget.company!;

                      data['categoryID'] = widget.accommodation!.categoryid;

                      data['accid'] = widget.accommodation!.id;
                      data['price'] = context
                          .read<AccommodationManager>()
                          .findAccommodationByID(widget.accommodation!.id)
                          ?.price;
                      data['status'] = 'tasked';
                      await hotelDBS.create(data);
                    } else {
                      //edit and update
                      await hotelDBS.updateData(widget.hotel!.id!, data);
                    }

                    //Navigator.pop(context);

                    Loader.hide();
                    Navigator.of(context).pushNamed('/myhotels');
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
                  FormBuilderDateTimePicker(
                    selectableDayPredicate: (DateTime val) {
                      if (val.weekday == 7 || val.weekday == 6) {
                        return false;
                      } else {
                        return true;
                      }
                    },
                    name: 'ini_date',
                    style: TextStyle(color: Colors.white),
                    initialValue: (dtNow),
                    fieldHintText: 'Inserir Data de entrada',
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
                      context.read<AccommodationManager>().updateDataIni(dtpar);
                      context
                          .read<AccommodationManager>()
                          .updateAcc(widget.accommodation!);
                    },
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
