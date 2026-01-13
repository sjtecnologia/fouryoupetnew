import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

class AdminUsersManager extends ChangeNotifier {
  List<Userapp> users = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  void updateUser(UserManager userManager) {
    _subscription?.cancel();

    if (userManager.adminEnabled) {
      _listenToUsers();
    } else {
      users.clear();
      notifyListeners();
    }
  }

  void _listenToUsers() {
    _subscription =
        firestore.collection('users').snapshots().listen((snapshot) {
      users = snapshot.docs.map((e) => Userapp.fromDocument(e)).toList();

      users.sort(
          (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));

      notifyListeners();
    });
  }

  List<String> get names => users.map((e) => e.name!).toList();

  Userapp findUserappByID(String id) {
    return users.firstWhere((p) => p.id == id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
