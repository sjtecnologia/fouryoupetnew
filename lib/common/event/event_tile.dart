import 'package:flutter/material.dart';

import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/event/event.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user/user_manager.dart';
import '../../screens/events/data/services/event_provider.dart';
import 'chat/chat_page_event.dart';

class EventTile extends StatefulWidget {
  const EventTile(this.event, {this.showControls = false});

  final AppEvent event;
  final bool showControls;

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> with TickerProviderStateMixin {
  late AnimationController controller;
  late int qtdmse = 0;
  String companyname = '';
  CompanyManager companyManager = CompanyManager();

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    context
        .read<EventProvider>()
        .getqtChats(widget.event.id ?? '')
        .then((v) => qtdmse = v);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    DateTime? dtaev = widget.event.event_date;

    double vlr_discount = widget.event.discount ?? 0;

    String formattedDate = DateFormat('dd-MM-yyyy - HH:mm').format(dtaev!);

    Future.delayed(Duration(seconds: 2));
    if (widget.event.status == 1 || widget.event.status == 2) {
      controller.stop();
    } else {
      controller
        ..forward(from: controller.value)
        ..repeat(reverse: true);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FutureBuilder(
                    future: _findCompanyByID(widget.event.companyID!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final cp = snapshot.data;
                        return Text(
                          cp.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                            //fontSize: 24,
                          ),
                        );
                      }
                      return Container();
                    }),
                Text(
                  'Data: ${formattedDate}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: Text(
                    'Serviço: ${widget.event.title.toString().toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Visibility(
                  visible: widget.event.description!.isNotEmpty,
                  child: Text(
                    'Obs: ${widget.event.description?.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                if(vlr_discount > 0)
                Text(
                  'Desconto: R\$ ${formatter.format(vlr_discount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Valor: R\$ ${formatter.format(widget.event.price! )}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                    fontSize: 18,
                  ),
                ),
                if(vlr_discount > 0)
                Text(
                  'Total: R\$ ${formatter.format(widget.event.price! - vlr_discount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.event.statusText.toUpperCase(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: widget.event.status == Status.canceled
                        ? Colors.red
                        : primaryColor,
                  ),
                ),
              ],
            ),
            IconButton(
              iconSize: 2,
              onPressed: () async {
                List<String>? tk = [];
                if (context.read<UserManager>().adminEnabled) {
                  if (context.read<UserManager>().userapp!.companyID ==
                      widget.event.companyID) {
                    tk = await context
                        .read<UserManager>()
                        .getToken(widget.event.userID.toString());
                  } else {
                    tk = await context.read<UserManager>().getToken(context
                            .read<UserManager>()
                            .findUserByCompanyID(widget.event.companyID) ??
                        '');
                  }
                } else {
                  tk = await context.read<UserManager>().getToken(context
                          .read<UserManager>()
                          .findUserByCompanyID(widget.event.companyID) ??
                      '');
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPageEvent(
                      groupId: widget.event.id.toString(),
                      userName: context.read<UserManager>().userapp?.name ?? '',
                      userToken: tk,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.chat,
                color: primaryColor,
                size: 30,
              ),
            ),
            // if (widget.event.status != Status.canceled)
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       SizedBox(width: 50),
            //       Icon(
            //         Icons.navigate_next,
            //         color: primaryColor,
            //       ),
            //     ],
            //   )
          ],
        ),
      ),
    );
  }

  Future<String?> _findCompanyByID(String id) async {
    return companyManager
        .findCompanyNameEndByID(id)!
        .then((value) => value?.name);
  }
}
