import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';

import 'package:fouryoupet/models/cart/cart_product.dart';

import 'package:fouryoupet/models/product/product.dart';
import 'package:fouryoupet/models/user/userapp.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/services/cepaberto_service.dart';
import 'package:geolocator/geolocator.dart';

import '../company/company.dart';

class CartManager extends ChangeNotifier {
  CartManager() {
    _loadCartItems();
    _loadUserAddress();
  }
  List<CartProduct> items = [];

  Userapp? user;
  Address? address;

  num productsPrice = 0.0;
  num? _discount = 0.0;
  String? _couponCode;
  num? deliveryPrice;
  String? companyID;
  bool? delivery = true;

  num? _trocopara;

  num? get trocopara => _trocopara ?? 0.0;

  num? get discount => _discount ?? 0.0;

  String? get couponCode => _couponCode;

  String? payId = 'Cartão Crédito';

  num get totalPrice => productsPrice + (deliveryPrice ?? 0);

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set trocopara(num? value) {
    _trocopara = value;
    //  notifyListeners();
  }

  set discount(num? value) {
    _discount = value;
    //  notifyListeners();
  }

  set couponCode(String? value) {
    _couponCode = value;
    //  notifyListeners();
  }

  void setDelivery(bool value) {
    delivery = value;

    notifyListeners();
  }

  List<Company> allCompany = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void updateUser(UserManager userManager) {
    user = userManager.userapp;
    productsPrice = 0.0;
    items.clear();
    removeAddress();

    if (user != null) {
      _loadCartItems();
      _loadUserAddress();
    }
  }

  Future<void> _loadCartItems() async {
    if (user != null) {
      final QuerySnapshot cartSnap = await user!.cartReference.get();

      items = cartSnap.docs
          .map((d) => CartProduct.fromDocument(d)..addListener(_onItemUpdated))
          .toList();
    }
  }

  Address get userAddress {
    _loadUserAddress();
    return address ?? Address();
  }

  Future<void> _loadUserAddress() async {
    if (user?.address?.where((a) => a.checked == true).first != null) {
      address = user!.address?.where((a) => a.checked == true).first;

      setAddress(address ?? Address());
    }
    notifyListeners();
  }

  bool addToCart(Product product) {
    final hasAnotherPetshop = items.any(
      (item) => item.companyID != product.companyID,
    );
    if (hasAnotherPetshop) return false;

    try {
      final e = items.firstWhere((p) => p.stackable(product));
      e.increment();
    } catch (e) {
      final cartProduct = CartProduct.fromProduct(product);
      cartProduct.addListener(_onItemUpdated);
      items.add(cartProduct);
      user!.cartReference
          .add(cartProduct.toCartItemMap())
          .then((doc) => cartProduct.id = doc.id);
      _loadUserAddress();
      _onItemUpdated();
    }
    return true;
  }

  void removeOfCart(CartProduct cartProduct) {
    items.removeWhere((p) => p.id == cartProduct.id);
    user!.cartReference.doc(cartProduct.id).delete();
    cartProduct.removeListener(_onItemUpdated);
    notifyListeners();
  }

  void clear() {
    for (final cartProduct in items) {
      user!.cartReference.doc(cartProduct.id).delete();
    }
    items.clear();
    notifyListeners();
  }

  void _onItemUpdated() {
    productsPrice = 0.0;

    for (int i = 0; i < items.length; i++) {
      final cartProduct = items[i];

      if (cartProduct.quantity == 0) {
        removeOfCart(cartProduct);
        i--;
        continue;
      }

      productsPrice += cartProduct.totalPrice;

      _updateCartProduct(cartProduct);
    }
    notifyListeners();
  }

  void _updateCartProduct(CartProduct cartProduct) {
    if (cartProduct.id != null) {
      user!.cartReference
          .doc(cartProduct.id)
          .update(cartProduct.toCartItemMap());
    }
  }

  bool get isCartValid {
    for (final cartProduct in items) {
      if (!cartProduct.hasStock) return false;
    }
    return true;
  }

  bool get isAddressValid =>
      user?.address?.where((a) => a.checked == true) != null &&
      deliveryPrice != null;

  // ADDRESS

  Future<void> getAddress(String cep) async {
    final cepAbertoService = CepAbertoService();
    loading = true;

    try {
      final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);

      // ignore: unnecessary_null_comparison
      if (cepAbertoAddress != null) {
        address = Address(
          street: cepAbertoAddress.logradouro,
          district: cepAbertoAddress.bairro,
          zipCode: cepAbertoAddress.cep,
          city: cepAbertoAddress.cidade.nome,
          state: cepAbertoAddress.estado.sigla,
          lat: cepAbertoAddress.latitude,
          long: cepAbertoAddress.longitude,
        );
      }
      loading = false;
    } catch (e) {
      loading = false;
      return Future.error('CEP Inválido');
    }
  }

  Future<void> setAddress(Address address) async {
    loading = true;

    this.address = address;
    deliveryPrice = 0;

    if (productsPrice > 0) if (await calculateDeliverynew()) {
      user!.setAddress(address);
      loading = false;
    } else {
      loading = false;
      return Future.error('Endereço fora do raio de entrega');
    }
    notifyListeners();
  }

  void removeAddress() {
    address = null;
    deliveryPrice = null;
    notifyListeners();
  }

  Future<bool> areacoberta() async {
    List<Company> cp = [];
    final QuerySnapshot doc = await firestore
        .collection('companys')
        .where('id', isEqualTo: items.first.companyID)
        .get();
    cp = doc.docs.map((d) => Company.fromDocument(d)).toList();

    final latStore = cp.last.address?.lat;
    final longStore = cp.last.address?.long;

    final maxkm = cp.last.maxkm ?? 0;

    double dis = await Geolocator.distanceBetween(
        latStore!,
        longStore!,
        user?.address?.where((a) => a.checked == true).first.lat ?? 0,
        user?.address?.where((a) => a.checked == true).first.long ?? 0);

    dis /= 1000.0;
    if (dis > maxkm) return Future.error('Endereço fora do raio de entrega');

    return true;
  }

  Future<bool> calculateDeliverynew() async {
    //deliveryPrice = 0.00;
    final QuerySnapshot doc = await firestore
        .collection('companys')
        .where('id', isEqualTo: items.first.companyID)
        .get();
    allCompany = doc.docs.map((d) => Company.fromDocument(d)).toList();
    if (allCompany.first.delivery ?? true) {
      final latStore = allCompany.last.address?.lat;
      final longStore = allCompany.last.address?.long;

      final base = allCompany.last.base ?? 0; //doc.get('base') as num?;
      final km = allCompany.last.km ?? 0; //doc.get('km') as num?;
      final maxkm = allCompany.last.maxkm ?? 0; //doc.get('maxkm') as num;
      final minkm = allCompany.last.minkm ?? 0; //doc.get('minkm') as num;

      double dis = await Geolocator.distanceBetween(
          latStore!,
          longStore!,
          user?.address?.where((a) => a.checked == true).first.lat ?? 0,
          user?.address?.where((a) => a.checked == true).first.long ?? 0);

      dis /= 1000.0;
      if (dis > minkm) {
        if (dis > maxkm) {
          return false;
        } else {
          delivery = true;
          deliveryPrice = base + dis * km;
          return true;
        }
      } else {
        delivery = true;
        deliveryPrice = 0.00;
        return true;
      }
    } else {
      delivery = false;
      deliveryPrice = 0.00;
      return true;
    }
  }

  void setTrocopara(num? value) {
    trocopara = value;
  }

  void setDesconto(num? value) {
    discount = value;
  }

  void setcouponCode(String? value) {
    couponCode = value;
  }
}
