import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fouryoupet/models/banner/banner.dart';

class BannerManager extends ChangeNotifier {
  List<Banner> banners = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  BannerManager() {
    _subscription?.cancel();
    _listenToBanners();
    //_loadAllBanners();
  }

  void _listenToBanners() async {
    banners.clear();
    _subscription =
        await firestore.collection('banner').snapshots().listen((event) {
      for (final doc in event.docs) {
        banners.add(Banner.fromDocument(doc));
      }
    });

    notifyListeners();
  }

  // List<Banner> allBanner = [];

  // Future<void> _loadAllBanners() async {
  //   final QuerySnapshot snapBanners =
  //       await firestore.collection('banner').get();
  //   allBanner = snapBanners.docs.map((d) => Banner.fromDocument(d)).toList();

  //   notifyListeners();
  // }

  // Banner? findBannerByID(String? id) {
  //   try {
  //     return allBanner.firstWhere((c) => c.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  void updateBanner() {
    _listenToBanners();
  }
}
