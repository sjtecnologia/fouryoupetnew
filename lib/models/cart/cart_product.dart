import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/product/product.dart';

import '../product/item_size.dart';

class CartProduct extends ChangeNotifier {
  CartProduct.fromProduct(this._product) {
    productId = product!.id;
    quantity = 1;
    sizes = product!.selectedSize!.name;
    companyID = product!.companyID;
    trocopara = 0;
  }

  CartProduct.fromDocument(DocumentSnapshot document) {
    id = document.id;
    productId = document.get('pid') as String?;
    quantity = document.get('quantity') as int?;
    sizes = document.get('sizes') as String?;
    companyID = document.get('companyID') as String?;

    trocopara = document.get('trocopara') as num? ?? 0;

    firestore.doc('products/$productId').get().then((doc) {
      product = Product.fromDocument(doc);
    });
  }

  CartProduct.fromMap(Map<String, dynamic> map) {
    productId = map['pid'] as String?;
    quantity = map['quantity'] as int?;
    sizes = map['sizes'] as String?;
    fixedPrice = map['fixedPrice'] as num?;
    companyID = map['companyID'] as String?;
    trocopara = map['trocopara'] as num? ?? 0;

    firestore.doc('products/$productId').get().then((doc) {
      product = Product.fromDocument(doc);
    });
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? id;

  String? productId;
  int? quantity;
  String? sizes;
  String? companyID;
  num? trocopara;
  String? payId;

  num? fixedPrice;

  Product? _product;
  Product? get product => _product;
  set product(Product? value) {
    _product = value;
    notifyListeners();
  }

  ItemSize? get itemSize {
    if (product == null) return null;
    return product!.findSize(sizes);
  }

  num get unitPrice {
    if (product == null) return 0;
    return itemSize?.price ?? 0;
  }

  num get totalPrice => unitPrice * quantity!;

  Map<String, dynamic> toCartItemMap() {
    return {
      'pid': productId,
      'quantity': quantity,
      'sizes': sizes,
      'companyID': companyID,
      'trocopara': trocopara,
    };
  }

  Map<String, dynamic> toOrderItemMap() {
    return {
      'pid': productId,
      'quantity': quantity,
      'sizes': sizes,
      'companyID': companyID,
      'fixedPrice': fixedPrice ?? unitPrice,
    };
  }

  bool stackable(Product product) {
    return product.id == productId && product.selectedSize!.name == sizes;
  }

  void increment() {
    quantity = (quantity! + 1);
    notifyListeners();
  }

  void decrement() {
    quantity = (quantity! - 1);
    notifyListeners();
  }

  bool get hasStock {
    if (product != null && product!.deleted!) return false;

    final sizes = itemSize;
    if (sizes == null) return false;
    return sizes.stock! >= quantity!;
  }
}
