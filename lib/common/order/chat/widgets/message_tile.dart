import 'package:flutter/material.dart';
import 'package:fouryoupet/models/order/orders_manager.dart';
import 'package:provider/provider.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final String time;
  final bool lido;
  final String orderId;
  final String userName;

  const MessageTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.sentByMe,
      required this.time,
      required this.lido,
      required this.orderId,
      required this.userName})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(Duration(seconds: 5));
      if (!widget.sentByMe) {
        await context
            .read<OrdersManager>()
            .updateStatusMessage(widget.orderId, widget.userName);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              widget.message + '  ' + widget.time,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Icon(
              Icons.check_circle_rounded,
              color: widget.lido ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
