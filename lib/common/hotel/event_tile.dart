import 'package:flutter/material.dart';
import 'package:fouryoupet/models/accommodation/accommodation_manager.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/hotel/hotel.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

import '../../helpers/utils.dart';

class HotelTile extends StatefulWidget {
  const HotelTile(this.hotel, {required this.showControls});

  final Hotel hotel;
  final bool showControls;

  @override
  State<HotelTile> createState() => _HotelTileState();
}

class _HotelTileState extends State<HotelTile> {
  String companyname = '';
  CompanyManager companyManager = CompanyManager();
  Userapp? _userapp;

  @override
  void initState() {
    companyname =
        companyManager.findCompanyByID(widget.hotel.companyID)?.name ?? '';
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user =
          await context.read<UserManager>().findUserByID(widget.hotel.userID);
      if (mounted) setState(() => _userapp = user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accomodation = context
        .read<AccommodationManager>()
        .findAccommodationByID(widget.hotel.accid)
        ?.name;
    final primaryColor = Theme.of(context).primaryColor;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    DateTime? dtaini = widget.hotel.ini_date;
    String formattedDateini = DateFormat('dd-MM-yyyy').format(dtaini!);
    DateTime? dtaend = widget.hotel.end_date;
    String formattedDateend = DateFormat('dd-MM-yyyy').format(dtaend!);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.showControls)
                  Text(
                    companyname.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      fontSize: 18,
                    ),
                  ),
                Text(
                  _userapp?.name?.toUpperCase() ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  accomodation?.toUpperCase() ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Data de entrada: ${formattedDateini} ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Data de saída: ${formattedDateend} ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Valor total das diárias: R\$ ${formatter.format(widget.hotel.price! * days_Dif(widget.hotel.ini_date as DateTime, widget.hotel.end_date as DateTime))}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     SizedBox(width: 80),
            //     Icon(
            //       Icons.navigate_next,
            //       color: primaryColor,
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
