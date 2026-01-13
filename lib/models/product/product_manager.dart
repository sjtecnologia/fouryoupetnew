import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/company/company.dart';
import 'package:fouryoupet/models/product/firebase_api.dart';
import 'package:fouryoupet/models/product/product.dart';

import 'package:fouryoupet/models/user/userapp.dart';
import 'package:geolocator/geolocator.dart';

class ProductManager extends ChangeNotifier {
  List<Product> products = [];
  List<Product> prodcs = [];

  List<Company>? company;

  List<String> cpids = [];

  bool _hasNext = true;
  bool get hasNext => _hasNext;

  set hasNext(bool value) {
    _hasNext = value;
  }

  Userapp? user;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    //notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  ProductManager() {
    _subscription?.cancel();

    _hasNext = true;
    _loading = false;

    //_listenToProducts();
  }

  Future<void> updatekeyword() async {
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

    final productsCollection =
        FirebaseFirestore.instance.collection('products');
    // Obtém todos os documentos da coleção de produtos
    final querySnapshot = await productsCollection.get();

    // Itera sobre cada documento
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final productName = data['name'] as String?;
      final description = data['description'] as String?;

      // Verifica se o nome do produto existe
      if (productName != null) {
        // Gera as keywords
        List<String> keywords;
        if (description != null) {
          keywords = _generateKeywords(productName + ' ' + description);
        } else
          keywords = _generateKeywords(productName);

        // Atualiza o documento com as keywords
        await doc.reference.update({'keywords': keywords});

        print('Documento ${doc.id} atualizado com sucesso!');
      } else {
        print('Nome do produto não encontrado no documento ${doc.id}');
      }
    }

    print('Atualização concluída!');
  }

  String _search = '';

  String? _companyID = '';

  String? _categoryid = '';

  String? get companyID => _companyID;
  int documentLimit = 20;
  final prodsSnapshot = <DocumentSnapshot>[];
  bool _isFetchingUsers = false;
  // ignore: unused_field
  String _errorMessage = '';

  set companyID(String? value) {
    _companyID = value;
    //  notifyListeners();
  }

  String? get categoryid => _categoryid;

  set categoryid(String? value) {
    _categoryid = value;
    // notifyListeners();
  }

  String get search => _search;

  set search(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> getCompanyIds() async {
    List<Company>? cpfilter = [];
    if (user != null && user?.address != null) {
      if (company != null)
        for (var c in company!) {
          var addressuser =
              user?.address!.where((u) => u.checked == true).first;
          final distancia = await GeolocatorPlatform.instance
                  .distanceBetween(
                      addressuser!.lat!.toDouble(),
                      addressuser.long!.toDouble(),
                      c.address!.lat!.toDouble(),
                      c.address!.long!.toDouble())
                  .toDouble() /
              1000;

          if (distancia.toDouble() <= c.maxkm!.toDouble() || c.id == '0') {
            cpfilter.add(c);
          }
        }
    } else {
      if (company != null)
        for (var c in company!) {
          var addressuser =
              await GeolocatorPlatform.instance.getCurrentPosition();
          final distancia = await GeolocatorPlatform.instance
                  .distanceBetween(
                      addressuser.latitude.toDouble(),
                      addressuser.longitude.toDouble(),
                      c.address!.lat!.toDouble(),
                      c.address!.long!.toDouble())
                  .toDouble() /
              1000;

          if (distancia.toDouble() <= c.maxkm!.toDouble() || c.id == '0') {
            cpfilter.add(c);
          }
        }
    }

    cpids.clear();
    for (var cp in cpfilter) {
      cpids.add(cp.id!);
    }
  }

  Future<List<Company>?> _loadAllCompanys() async {
    try {
      final QuerySnapshot snapProducts = await firestore
          .collection('companys')
          .where('active', isEqualTo: true)
          .get()
          .timeout(Duration(seconds: 10));
      company = snapProducts.docs.map((d) => Company.fromDocument(d)).toList();
    } catch (e, s) {
      log('Erro ao buscar fornecedores', error: e, stackTrace: s);
      return null;
    }
    return null;
  }

  Future fetchNextProds() async {
    loading = true;
    await _loadAllCompanys();
    if (_isFetchingUsers) {
      loading = false;
      return;
    }

    if (cpids.isEmpty) await getCompanyIds();

    //_loading = true;
    if (companyID != '0' &&
        companyID != '' &&
        categoryid != '0' &&
        categoryid != '') {
      try {
        _isFetchingUsers = true;
        _errorMessage = '';

        final snap = await FirebaseApi.getProducts(
          documentLimit,
          companyID!,
          categoryid!,
          startAfter: prodsSnapshot.isNotEmpty ? prodsSnapshot.last : null,
        );
        prodsSnapshot.addAll(snap.docs);

        prodcs = (prodsSnapshot.map((snap) {
          final prod = json.encode(snap.data());

          final prodfinal =
              "{" '"id":' + '"' + snap.id + '",' + prod.substring(1);

          return Product.fromJson(prodfinal);
        }).toList());

        if (snap.docs.length < documentLimit) _hasNext = false;
        notifyListeners();
      } catch (error) {
        _errorMessage = error.toString();
        notifyListeners();
      }
    } else {
      if (companyID != '0' &&
          companyID != '' &&
          (categoryid == '0' || categoryid == '')) {
        try {
          _isFetchingUsers = true;
          _errorMessage = '';

          final snap = await FirebaseApi.getProductanycatcp(
            documentLimit,
            companyID!,
            startAfter: prodsSnapshot.isNotEmpty ? prodsSnapshot.last : null,
          );
          //prodcs.clear();
          prodsSnapshot.addAll(snap.docs);
          prodcs = (prodsSnapshot.map((snap) {
            final prod = json.encode(snap.data());

            final prodfinal =
                "{" '"id":' + '"' + snap.id + '",' + prod.substring(1);

            return Product.fromJson(prodfinal);
          }).toList());

          if (snap.docs.length < documentLimit) _hasNext = false;
          notifyListeners();
        } catch (error) {
          _errorMessage = error.toString();
          notifyListeners();
        }
      } else {
        if ((companyID == '0' || companyID == '') &&
            categoryid != '0' &&
            categoryid != '') {
          try {
            _isFetchingUsers = true;
            _errorMessage = '';

            //print(cpids);

            final snap = await FirebaseApi.getProductanycpcat(
              documentLimit,
              cpids,
              categoryid!,
              startAfter: prodsSnapshot.isNotEmpty ? prodsSnapshot.last : null,
            );

            prodcs = (snap.map((snap) {
              final prod = json.encode(snap.data());

              final prodfinal =
                  "{" '"id":' + '"' + snap.id + '",' + prod.substring(1);

              return Product.fromJson(prodfinal);
            }).toList());
            prodcs.sort(
              (a, b) => a.name!.compareTo(b.name!),
            );

            if (snap.length < documentLimit) _hasNext = false;
            notifyListeners();
          } catch (error) {
            _errorMessage = error.toString();
            notifyListeners();
          }
        } else {
          try {
            _isFetchingUsers = true;
            _errorMessage = '';

            // print(cpids);

            final snap = await FirebaseApi.getProductanycatandcp(
              cpids,
              startAfter: prodsSnapshot.isNotEmpty ? prodsSnapshot.last : null,
            );

            prodcs = (snap.map((snap) {
              final prod = json.encode(snap.data());

              final prodfinal =
                  "{" '"id":' + '"' + snap.id + '",' + prod.substring(1);

              return Product.fromJson(prodfinal);
            }).toList());
            prodcs.sort(
              (a, b) => a.name!.toUpperCase().compareTo(b.name!.toUpperCase()),
            );

            if (snap.length < documentLimit) _hasNext = false;
            loading = false;
            notifyListeners();
          } catch (error) {
            _errorMessage = error.toString();
            loading = false;
            notifyListeners();
          }
        }
      }
    }
    loading = false;
    _isFetchingUsers = false;
  }

  List<Product> get filteredProducts {
    final List<Product> filteredProducts = [];
    var adm = user?.admin;

    if (search.isEmpty) {
      if (categoryid == '0' && adm == true) {
        filteredProducts.addAll(prodcs);
      } else {
        filteredProducts.addAll(
            prodcs.where((p) => p.images!.length > 0 && p.hasStock == true));
      }
    } else {
      //fetchNextProdssearch();
      if (companyID != '0') fetchNextProdssearch();
      if (categoryid == '0' && user!.admin) {
        filteredProducts.addAll(prodcs.where((p) => removeDiacritics(p.name!)
            .toLowerCase()
            .contains(removeDiacritics(search).toLowerCase())));
      } else {
        filteredProducts.addAll(
          prodcs.where(
            (p) =>
                removeDiacritics(p.name!).toLowerCase().contains(
                      removeDiacritics(search).toLowerCase(),
                    ) &&
                (p.images!.length > 0) &&
                (p.hasStock == true),
          ),
        );
      }
      if (filteredProducts.isEmpty) {
        documentLimit = 20;
        // _isFetchingUsers = false;
        // fetchNextProds();
        documentLimit = 20;
      }
      // } else {
      //   _hasNext = false;
      //   //_isFetchingUsers = true;
      // }
    }

    return filteredProducts;
  }

  Future fetchNextProdssearch() async {
    //loading = true;

    if (_isFetchingUsers) {
      loading = false;
      return;
    }
    try {
      _isFetchingUsers = true;
      _errorMessage = '';
      final snap = await FirebaseApi.getProductcpall(
        companyID!,
        categoryid!,
        startAfter: prodsSnapshot.isNotEmpty ? prodsSnapshot.last : null,
      );
      prodsSnapshot.addAll(snap.docs);

      prodcs = (prodsSnapshot.map((snap) {
        final prod = json.encode(snap.data());

        final prodfinal =
            "{" '"id":' + '"' + snap.id + '",' + prod.substring(1);

        return Product.fromJson(prodfinal);
      }).toList());

      if (snap.docs.length < documentLimit) _hasNext = false;
      notifyListeners();

      _isFetchingUsers = false;
    } catch (error) {
      _errorMessage = error.toString();
      //    loading = false;
      notifyListeners();
    }
    // loading = false;
  }

  Product? findProductByID(String? id) {
    try {
      return prodcs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void delete(Product product) {
    product.delete();
    prodcs.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  void update(Product product) {
    prodcs.removeWhere((p) => p.id == product.id);
    if (product.companyID == null) product.companyID = this.user!.companyID;

    prodcs.add(product);

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    prodsSnapshot.clear();
  }

  void updateUser(Userapp? user) {
    this.user = user;
  }

  void setCompanid(String value) {
    companyID = value;
  }
}
