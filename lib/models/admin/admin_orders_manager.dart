import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import '../order/order.dart' as od;

class AdminOrdersManager extends ChangeNotifier {
  final List<od.Order> _orders = [];

  Userapp? userFilter;
  List<od.Status?> statusFilter = [
    od.Status.approval,
    od.Status.delivered,
    od.Status.preparing,
    od.Status.transporting,
    od.Status.canceled
  ];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  // ignore: avoid_positional_boolean_parameters
  void updateAdmin(bool adminEnabled, String? companyID) {
    _orders.clear();

    _subscription?.cancel();
    if (adminEnabled) {
      if (companyID != null)
        _listenToOrders(companyID);
      else
        _listenToOrders('');
    }
  }

  List<od.Order> get filteredOrders {
    List<od.Order> output = _orders.reversed.toList();

    if (userFilter != null) {
      output = output.where((o) => o.userId == userFilter!.id).toList();
    }

    return output =
        output.where((o) => statusFilter.contains(o.status)).toList();
  }

  void _listenToOrders(String companyID) {
    _subscription = firestore
        .collection('orders')
        .where('companyID', isEqualTo: companyID)
        .orderBy('date', descending: false)
        .snapshots()
        .listen((event) {
      for (final change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            _orders.add(od.Order.fromDocument(change.doc));
            break;
          case DocumentChangeType.modified:
            final modOrder = _orders.firstWhere(
                (o) => o.orderId == change.doc.id && o.companyID == companyID);
            modOrder.updateFromDocument(change.doc);
            break;
          case DocumentChangeType.removed:
            break;
        }
      }

      notifyListeners();
    });
  }

  void setUserFilter(Userapp? user) {
    userFilter = user;
    notifyListeners();
  }

  void setStatusFilter({od.Status? status, required bool enabled}) {
    if (enabled) {
      statusFilter.add(status);
    } else {
      statusFilter.remove(status);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}
