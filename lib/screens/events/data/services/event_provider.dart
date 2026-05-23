import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/couponcodes/couponcode_manager.dart';
import 'package:fouryoupet/models/event/event.dart';
import 'package:fouryoupet/models/user/userapp.dart';

class EventProvider extends ChangeNotifier {
  EventProvider() {
    getqtChats2();
  }
  final List<AppEvent> _events = [];
  String? eventId;
  int? qtdmsge = 0;

  List<AppEvent> allEvent = [];
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    //notifyListeners();
  }

  Future<List<AppEvent>> loadAllAppEvent(
      bool? type, DateTime event_date, String companyID) async {
    loading = true;

    allEvent.clear();
    final QuerySnapshot snapEvents = await firestore
        .collection('events')
        .where('type', isEqualTo: type)
        .where('event_date', isGreaterThanOrEqualTo: event_date)
        .where('event_date', isLessThanOrEqualTo: event_date)
        .where('companyID', isEqualTo: companyID)
        .get();
    if (snapEvents.size > 0)
      allEvent.add(snapEvents.docs.map((d) => AppEvent.fromDocument(d)).first);

    for (var cp
        in (snapEvents.docs.map((d) => AppEvent.fromDocument(d)).toList())) {
      allEvent.add(cp);
    }

    loading = false;
    return allEvent;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference get firestoreRef =>
      firestore.collection('events').doc(eventId);
  CollectionReference get groupReference => firestoreRef.collection('messeges');

  List<AppEvent> get events => _events;

  AppEvent appEvent = AppEvent();

  String? _companyID = '';

  String? get cpid => _companyID;

  void setCompanyID(String? id) => _companyID = id;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<AppEvent> get eventsofSelectedDate => _events;

  //List<AppEvent> get eventsofUser => _events;

  void addEvent(AppEvent event) {
    _events.add(event);

    notifyListeners();
  }

  Userapp? user;

  StreamSubscription? _subscription;

  void updateUser(Userapp? user, bool tp, int type) async {
    this.user = user;
    events.clear();

    _subscription?.cancel();
    if (user != null) {
      _listenToEvents();
      if (user.companyID != null && type == 1) {
        _listenToEventsCp(tp);
      }
    }
  }

  void upeUser(
    Userapp? user,
  ) async {
    this.user = user;
    getqtChats2();
  }

  // getting the chats
  getChats(String groupId) async {
    eventId = groupId;
    return groupReference.orderBy("time").snapshots();
  }

  Future<int> getqtChats(String groupId) async {
    eventId = groupId;
    var teste = await groupReference
        .where('lido', isEqualTo: false)
        .where('sender', isNotEqualTo: user?.name)
        .get();
    return teste.size;
  }

  Future<int> getqtChats2() async {
    var teste = await groupReference
        .where('lido', isEqualTo: false)
        .where('sender', isNotEqualTo: user?.name)
        .get();
    return teste.size;
  }

  Future<void> updateStatusMessage(String orderId, String userName) async {
    final ordersCollection = FirebaseFirestore.instance.collection('events');

    final querySnapshot = await ordersCollection.get();

    for (final orderDoc in querySnapshot.docs.where((e) => e.id == orderId)) {
      final messagesCollection = orderDoc.reference
          .collection('messeges')
          .where('lido', isEqualTo: false)
          .where('sender', isNotEqualTo: userName);
      final messagesQuerySnapshot = await messagesCollection.get();

      for (final messageDoc in messagesQuerySnapshot.docs) {
        final data = messageDoc.data();
        if (data.containsKey('lido')) {
          // Adicione o campo "lido" com o valor inicial "false"

          await messageDoc.reference.set({
            'lido': true,
          }, SetOptions(merge: true));
        }
      }
    }
  }

  Future<void> adicionarCampoLido() async {
    final ordersCollection = FirebaseFirestore.instance.collection('events');

    final querySnapshot = await ordersCollection.get();

    for (final orderDoc in querySnapshot.docs) {
      final messagesCollection = orderDoc.reference.collection('messeges');
      final messagesQuerySnapshot = await messagesCollection.get();

      for (final messageDoc in messagesQuerySnapshot.docs) {
        final data = messageDoc.data();
        if (!data.containsKey('lido')) {
          // Adicione o campo "lido" com o valor inicial "false"
          await messageDoc.reference.set({
            'lido': false,
          }, SetOptions(merge: true));
        }
      }
    }

    debugPrint('Campos "lido" adicionados aos documentos existentes.');
  }

  Future<int?>? qtdMessage() async {
    if (user != null) await _contarMensagensNaoLidas();

    return qtdmsge;
  }

  Future<void> _contarMensagensNaoLidas() async {
    qtdmsge = 0;
    final ordersCollection = FirebaseFirestore.instance.collection('events');

    final querySnapshot =
        await ordersCollection.where('userID', isEqualTo: user!.id).get();

    for (final orderDoc in querySnapshot.docs) {
      final messagesCollection = orderDoc.reference
          .collection('messeges')
          .where('lido', isEqualTo: false)
          .where('sender', isNotEqualTo: user?.name);
      final messagesQuerySnapshot = await messagesCollection.get();
      if (messagesQuerySnapshot.size > 0) {
        qtdmsge = qtdmsge! + messagesQuerySnapshot.size;
      }
    }

    notifyListeners();
  }

  Future<void> checkout({
    String? orderId,
    String? userId,
    CouponCodeManager? couponManager,
  }) async {
    loading = true;

   

    // Register coupon usage if a coupon was applied
    if (couponManager != null && couponManager.hasCouponApplied) {
      await couponManager.markCouponAsUsed(
        userId.toString(),
        orderId.toString(),
      );
    }
    loading = false;
  }

  void _listenToEvents() async {
    _subscription = firestore
        .collection('events')
        .where('userID', isEqualTo: user!.id)
        .orderBy('event_date')
        .orderBy('serviceid')
        .snapshots()
        .listen((event) {
      events.clear();
      for (final doc in event.docs) {
        events.add(AppEvent.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  void _listenToEventsCp(bool tp) async {
    _subscription = firestore
        .collection('events')
        .where('companyID', isEqualTo: user!.companyID)
        .where('type', isEqualTo: tp)
        .orderBy('event_date')
        .orderBy('serviceid')
        .snapshots()
        .listen((event) {
      events.clear();
      for (final doc in event.docs) {
        events.add(AppEvent.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}
