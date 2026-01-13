import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/product/item_size.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:uuid/uuid.dart';

class Product extends ChangeNotifier {
  final Userapp? userapp;

  Product(
      {this.id,
      this.userapp,
      this.name,
      this.description,
      this.companyID,
      this.categoryid,
      this.type,
      this.images,
      this.sizes,
      this.deleted = false}) {
    images = images ?? [];
    sizes = sizes ?? [];
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) {
    return Product.fromMap((json.decode(source)));
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'companyID': companyID,
      'categoryid': categoryid,
      'type': type,
      'images': images,
      'sizes': sizes?.map((x) => x.toMap()).toList(),
      'newImages': newImages,
      'deleted': deleted,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      companyID: map['companyID'] != null ? map['companyID'] as String : null,
      categoryid:
          map['categoryid'] != null ? map['categoryid'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      images: map['images'] != null
          ? (map['images'] as List).map<String>((image) => image).toList()
          : null,
      sizes: map['sizes'] != null
          ? (map['sizes'] as List).map((s) => ItemSize.fromMap(s)).toList()
          : null,
      deleted: map['deleted'] != null ? map['deleted'] as bool : null,
    );
  }

  Product.fromDocument(DocumentSnapshot document, {this.userapp}) {
    id = document.id;
    name = document['name'] as String?;
    description = document['description'] as String?;
    companyID = document['companyID'] as String?;
    categoryid = document['categoryid'] as String?;
    type = document['type'] as String?;
    images = List<String>.from(document.get('images') as List<dynamic>);
    deleted = (document.get('deleted') ?? false) as bool;
    sizes = (document.get('sizes') as List<dynamic>? ?? [])
        .map((s) => ItemSize.fromMap(s as Map<String, dynamic>))
        .toList();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('products/$id');
  Reference get storageRef => storage.ref().child('products').child(id!);

  String? id;
  String? name;
  String? description;
  String? companyID;
  String? categoryid;

  String? type = 'P';
  List<String>? images;
  List<ItemSize>? sizes;
  List<dynamic>? newImages;
  bool? deleted;
  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  ItemSize? _selectedSize;
  ItemSize? get selectedSize => _selectedSize;

  set selectedSize(ItemSize? value) {
    _selectedSize = value;
    notifyListeners();
  }

  int get totalStock {
    int stock = 0;
    for (final size in sizes!) {
      stock += size.stock!;
    }
    return stock;
  }

  bool get hasStock {
    return totalStock > 0 && !deleted!;
  }

  num? get basePrice {
    num? lowest = double.infinity;
    for (final size in sizes!) {
      if (size.price! < lowest!) {
        lowest = size.price;
      }
    }
    return lowest;
  }

  // Função para gerar as keywords
  List<String> _generateKeywords(String text) {
    final words = removeDiacritics(text).toLowerCase().split(' ');
    final keywords = <String>[];
    for (var word in words) {
      for (var i = 0; i < word.length; i++) {
        for (var j = i + 1; j <= word.length; j++) {
          keywords.add(word.substring(i, j));
        }
      }
    }
    return keywords;
  }

  ItemSize? findSize(String? name) {
    try {
      return sizes!.firstWhere((s) => s.name == name);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> exportSizeList() {
    return sizes!.map((size) => size.toMap()).toList();
  }

  Future<void> save() async {
    loading = true;
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'companyID': companyID,
        'categoryid': categoryid,
        'type': 'P',
        'sizes': exportSizeList(),
        'deleted': deleted,
        'keywords': _generateKeywords(name! + '' + description!),
      };

      if (id == null) {
        final doc = await firestore.collection('products').add(data);
        id = doc.id;
      } else {
        await firestoreRef.update(data);
      }

      final List<String> updateImages = [];

      for (final newImage in newImages!) {
        if (images!.contains(newImage)) {
          updateImages.add(newImage as String);
        } else {
          final UploadTask task =
              storageRef.child(Uuid().v1()).putFile(newImage as File);
          final TaskSnapshot snapshot = await task;
          final String url = await snapshot.ref.getDownloadURL();
          updateImages.add(url);
        }
      }
      for (final image in images!) {
        if (!newImages!.contains(image) && image.contains('firebase')) {
          try {
            final ref = await storage.refFromURL(image);
            await ref.delete();
          } catch (e) {
            debugPrint('Falha ao deletar $image');
          }
        }
      }
      await firestoreRef.update({'images': updateImages});
      images = updateImages;
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
    }
    loading = false;
  }

  void delete() {
    firestoreRef.update({'deleted': true});
  }

  Product clone() {
    return Product(
      userapp: userapp,
      id: id,
      name: name,
      companyID: companyID,
      categoryid: categoryid,
      description: description,
      type: type,
      images: List.from(images!),
      sizes: sizes!.map((size) => size.clone()).toList(),
      deleted: deleted,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, companyID: $companyID, categoryid: $categoryid, type: $type, images: $images, sizes: $sizes, newImages: $newImages, deleted: $deleted)';
  }
}
