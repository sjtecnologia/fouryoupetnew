import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/common/order/chat/chat_page.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/order/order.dart';
import 'package:fouryoupet/common/order/order_product_tile.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order/orders_manager.dart';
import 'cancel_order_dialog.dart';
import 'export_address_dialog.dart';

class OrderTile extends StatefulWidget {
  const OrderTile(this.order, {this.showControls = false});

  final Order order;
  final bool showControls;

  @override
  State<OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> with TickerProviderStateMixin {
  late AnimationController controller;
  late int qtdms = 0;

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
        .read<OrdersManager>()
        .getqtChats(widget.order.orderId ?? '')
        .then((v) => qtdms = v);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userorder =
        context.read<UserManager>().findUserByID(widget.order.userId);
    var companyselec =
        context.read<CompanyManager>().findCompanyByID(widget.order.companyID);
    final desconto = widget.order.discount ?? 0.0;
    final vlrfrete = widget.order.frete ?? 0.0;
    Future.delayed(Duration(seconds: 2));
    if (widget.order.status == 0 || widget.order.status == 4) {
      controller.stop();
    } else {
      controller
        ..forward(from: controller.value)
        ..repeat(reverse: true);
    }
    if (companyselec == null)
      companyselec = context
          .read<CompanyManager>()
          .findCompanyByID(widget.order.companyID);

    final primaryColor = Theme.of(context).primaryColor;
    final formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: "", decimalDigits: 2);
    final wd = MediaQuery.of(context).size.width;
    //final hd = MediaQuery.of(context).size.height;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: wd * .35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    'Pedido: ${widget.order.formattedId}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FutureBuilder(
                      future: _findCompanyByID(widget.order.companyID!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final cp = snapshot.data;

                          if (widget.showControls)
                            return Text(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              userorder?.name?.toUpperCase() ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black45,
                                fontSize: 10.5,
                              ),
                            );
                          return Text(
                            maxLines: 2,
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
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    UtilData.obterDataDDMMAAAA(widget.order.date!.toDate()) +
                        ' ' +
                        UtilData.obterHoraHHMM(widget.order.date!.toDate()),
                    // DateFormat('dd/m/yyyy, HH:mm')
                    //     .format(widget.order.date!.toDate()),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    'À pagar: R\$ ${formatter.format(widget.order.price! - desconto)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  if (widget.order.discount != null && desconto > 0) ...{
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      'Desconto: R\$ ${formatter.format(widget.order.discount!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  },
                  const SizedBox(
                    height: 5,
                  ),
                  if (companyselec?.delivery == null ||
                      companyselec?.delivery == true && vlrfrete > 0)
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      'Frete: R\$ ${formatter.format(widget.order.frete!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  if (companyselec?.delivery == false)
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      'Retirada no local',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    widget.order.payId.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Visibility(
                    visible: widget.order.payId == 'Dinheiro',
                    child: Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      'Troco para: R\$ ${formatter.format(widget.order.trocopara!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Text(
                      widget.order.statusText,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: widget.order.status == Status.canceled
                            ? Colors.red
                            : primaryColor,
                      ),
                    ),
                    Badge(
                      isLabelVisible: qtdms > 0,
                      label: Text(qtdms.toString()),
                      child: IconButton(
                        onPressed: () async {
                          List<String>? tk = [];
                          if (context.read<UserManager>().adminEnabled) {
                            if (context
                                    .read<UserManager>()
                                    .userapp!
                                    .companyID ==
                                widget.order.companyID) {
                              tk = await context
                                  .read<UserManager>()
                                  .getToken(widget.order.userId.toString());
                            } else {
                              tk = await context.read<UserManager>().getToken(
                                  context
                                          .read<UserManager>()
                                          .findUserByCompanyID(
                                              widget.order.companyID) ??
                                      '');
                            }
                          } else {
                            tk = await context.read<UserManager>().getToken(
                                context.read<UserManager>().findUserByCompanyID(
                                        widget.order.companyID) ??
                                    '');
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                groupId: widget.order.orderId.toString(),
                                userName:
                                    context.read<UserManager>().userapp?.name ??
                                        '',
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
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        children: <Widget>[
          Column(
            children: widget.order.items!.map((e) {
              return OrderProductTile(e, widget.order);
            }).toList(),
          ),
          if (widget.showControls && widget.order.status != Status.canceled)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => CancelOrderDialog(widget.order));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.order.back,
                    child: const Text('Recuar'),
                  ),
                  TextButton(
                    onPressed: widget.order.advance,
                    child: const Text('Avançar'),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) =>
                              ExportAddressDialog(widget.order.address));
                    },
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                    child: const Text('Endereço'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _findCompanyByID(String id) async {
    return context
        .read<CompanyManager>()
        .findCompanyNameEndByID(id)!
        .then((value) => value?.name);
  }
}
