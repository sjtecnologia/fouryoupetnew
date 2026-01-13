import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:fouryoupet/models/notificatificacao/notifi.dart';

import 'package:fouryoupet/models/notificatificacao/notifications.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import '../user/userapp.dart';

class NotificationsManager extends ChangeNotifier {
  NotificationsManager() {
    stNotificnolido();
    _listenToNotifications(UserManager().userapp);
  }

  Userapp? user;

  Notifications? notifications = new Notifications();
  Notifications? notificationsnolido = new Notifications();

  int? qtdnf = 0;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> _listenToNotifications(Userapp? userapp) async {
    var usr = userapp?.id;

    final DocumentSnapshot docNotifi =
        await firestore.collection('notifications').doc(usr).get();
    if (docNotifi.exists) {
      notifications = await Notifications.fromDocument(docNotifi);
    }

    notifyListeners();
  }

  Future<void> _listenToNotificationsnolido(Userapp? userapp) async {
    var usr = userapp?.id;

    final DocumentSnapshot docNotifi =
        await firestore.collection('notifications').doc(usr).get();

    if (docNotifi.exists)
      notifications = await Notifications.fromDocument(docNotifi);
    qtdnf = 0;
    notifications?.notif?.forEach((n) {
      if (n.lido == false) qtdnf = qtdnf! + 1;
    });
    //var teste = docNotifi.docs;
    //print(qtd);

    notifyListeners();
  }

  Future<void> setNotifi(Notifi? notifi) async {
    loading = true;
    await findUser();
    await _listenToNotifications(user);
    final nt = notifications;
    nt?.id = user?.id;
    this.notifications = nt;
    if (notifi != null) this.notifications?.setNotifi(notifi);
    await _listenToNotifications(user);
    notifications = this.notifications;
    loading = false;
    notifyListeners();
  }

  Future<void> updatentf(Notifications? notifi) async {
    if (notifi!.id == null) notifi.id = user!.id;
    this.notifications!.updatenf(notifi);
    await stNotificnolido();
    notifyListeners();
  }

  Future<void> stNotific() async {
    loading = true;
    await findUser();
    await _listenToNotifications(user);
    final nt = notifications;
    nt?.id = user?.id;
    notifications = nt;

    loading = false;
    notifyListeners();
  }

  Future<int?>? stNotificnolido() async {
    loading = true;
    // await findUser();
    await _listenToNotificationsnolido(user);
    loading = false;
    return qtdnf;
  }

  Future<void> updateUser(Userapp? user) async {
    this.user = user;
    notifications = Notifications();
    if (user != null) {
      _listenToNotifications(user);
      await _listenToNotificationsnolido(user);
      //FlutterAppBadger.updateBadgeCount(qtdnf ?? 0);
    }
    return null;
  }

  Future<void> findUser() async {
    user = await UserManager().finduser();
  }
}
