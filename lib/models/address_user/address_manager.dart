import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address_user/address_user.dart';

import '../address/address.dart';
import '../user/user_manager.dart';
import '../user/userapp.dart';

class AddressManager extends ChangeNotifier {
  List<AddressUser> addressusers = [];

  Userapp? user;
  Address? address;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void updateUser(UserManager userManager) {
    user = userManager.userapp;
    addressusers.clear();
    //removeAddress();

    if (user != null) {
      _loadAddressUser();
    }
  }

  Future<void> _loadAddressUser() async {
    final QuerySnapshot addressSnap = await user!.cartReference.get();

    addressusers = addressSnap.docs
        .map((d) => AddressUser.fromDocument(d)..addListener(_onItemUpdated))
        .toList();
  }

  void _onItemUpdated() {
    for (int i = 0; i < addressusers.length; i++) {
      final addressUserapp = addressusers[i];

      _updateAddressUser(addressUserapp);
    }
    notifyListeners();
  }

  void _updateAddressUser(AddressUser addressUser) {
    if (addressUser.id != null) {
      user!.cartReference
          .doc(addressUser.id)
          .update(addressUser.toUserAddressMap());
    }
  }

  void addToAddress(Address address, Userapp userapp) {
    final addressUser = AddressUser.fromAddress(address, userapp);
    addressUser.addListener(_onItemUpdated);
    addressusers.add(addressUser);
    user!.cartReference
        .add(addressUser.toUserAddressMap())
        .then((doc) => addressUser.id = doc.id);
    _onItemUpdated();
  }
}
