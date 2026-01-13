import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';
import 'package:fouryoupet/models/accommodation/accommodation_manager.dart';

import 'package:fouryoupet/models/hotel/hotel.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/hotel/hotel_firestore_service.dart';
import '../../models/user/user_manager.dart';

class AddHt extends StatefulWidget {
  final DateTime? selectedDate;
  final Hotel? hotel;
  final String? company;
  final int? homeclic;
  final Accommodation? accommodation;

  const AddHt({
    Key? key,
    this.selectedDate,
    this.hotel,
    this.company,
    this.homeclic,
    this.accommodation,
  }) : super(key: key);

  @override
  _AddHtState createState() => _AddHtState();
}

class _AddHtState extends State<AddHt> {
  final selectedIndexNotifier = ValueNotifier<int?>(null);
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final DateRangePickerController _dateRangePickerController =
        DateRangePickerController();
    context
        .read<AccommodationManager>()
        .updateAcc(widget.accommodation as Accommodation);
    context.read<AccommodationManager>().filteredHotel;

    //tm = context.read<AccommodationManager>().hoursfree;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title:
            Text('Agendar Hospedagens', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfDateRangePicker(
                view: DateRangePickerView.month,
                monthViewSettings:
                    DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                selectionMode: DateRangePickerSelectionMode.range,
                showActionButtons: true,
                controller: _dateRangePickerController,
                rangeSelectionColor: Colors.orangeAccent,
                backgroundColor: Colors.white,
                minDate: DateTime.now(),
                rangeTextStyle: const TextStyle(
                  color: Colors.white,
                ),
                startRangeSelectionColor: primaryColor,
                endRangeSelectionColor: primaryColor,
                todayHighlightColor: primaryColor,
                selectionColor: primaryColor,
                cancelText: 'Cancelar',
                confirmText: 'Salvar',
                onSubmit: _onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onSubmit(Object? p1) async {
    if (p1 is PickerDateRange) {
      var exitevagaini =
          context.read<AccommodationManager>().exitevaga(p1.startDate);
      var exitevagaend =
          context.read<AccommodationManager>().exitevaga(p1.endDate);
      if (exitevagaini! && exitevagaend!) {
        _formKey.currentState!.save();
        final data = Map<String, dynamic>.from(_formKey.currentState!.value);
        if (widget.hotel == null) {
          data['userID'] = context.read<UserManager>().userapp!.id;
          data['ini_date'] = p1.startDate;
          data['end_date'] = p1.endDate;
          data['companyID'] = widget.company!;

          data['categoryID'] = widget.accommodation!.categoryid;

          data['accid'] = widget.accommodation!.id;

          data['price'] = context
              .read<AccommodationManager>()
              .findAccommodationByID(widget.accommodation!.id)
              ?.price;
          await hotelDBS.create(data);
        } else {
          await hotelDBS.updateData(widget.hotel!.id!, data);
        }

        Navigator.of(context).pushNamed('/myhotels');
      } else {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "Período indisponível, favor escolher outro",
          ),
        );
      }
    }
  }
}
