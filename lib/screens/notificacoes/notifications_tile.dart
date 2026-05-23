import 'package:flutter/material.dart';
import 'package:fouryoupet/models/notificatificacao/notifi.dart';
import 'package:intl/intl.dart';
import 'package:fouryoupet/common/app_network_image.dart';

class NotificationsTile extends StatelessWidget {
  const NotificationsTile(this.notifications, {this.showControls = false});

  final Notifi notifications;
  final bool showControls;

  @override
  Widget build(BuildContext context) {
    //final primaryColor = Theme.of(context).primaryColor;
    final wd = MediaQuery.of(context).size.width;
    // final hd = MediaQuery.of(context).size.height;
    bool ld = notifications.lido ?? false;
    return Card(
      color: ld ? Colors.white38 : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  if (notifications.image != null && notifications.image != '')
                    Container(
                      width: wd * .80,
                      child: Center(
                        child: AppNetworkImage(
                          imageUrl: notifications.image.toString(),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: wd * .80,
                    child: Text(
                      notifications.notificationTitle.toString(),
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    width: wd * .80,
                    child: Text(
                      notifications.notificationBody.toString() +
                          '\n' +
                          _formatDate(notifications.notificationDate!.toDate()),
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (notifications.lido == true)
              Icon(
                Icons.check,
                color: Colors.green,
              )
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy - HH:mm:ss').format(date);
  }
}
