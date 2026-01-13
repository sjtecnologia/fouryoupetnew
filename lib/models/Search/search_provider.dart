import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';

import 'package:fouryoupet/models/product/product.dart';

import '../service/service.dart';
import 'search_result.dart';
// Importe o modelo SearchResult

class SearchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SearchResult> _searchResults = [];

  List<SearchResult> get searchResults => _searchResults;

  bool _isLoading = false; // Controla o estado de carregamento
  bool get isLoading => _isLoading;

  // int _type = 0;
  // int get type => _type;
  int? tp;

  //Objeto produto
  final _product = Product();
  final _service = Service();

  Product get product => _product;

  Service get service => _service;

  Future<void> search(String query, int type) async {
    tp = type;
    _isLoading = true;
    notifyListeners();
    _searchResults.clear(); // Limpa os resultados anteriores

    // Realiza as buscas em paralelo para melhor performance
    final companyFuture = _searchCompanies(query);
    final productFuture = _searchProducts(query);
    final cuidadosFuture = _searchCuidados(query);
    final vetFuture = _searchVet(query);
    final accommodationFuture = _searchAccommodation(query);

    if (query.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    switch (type) {
      case 0:
        {
          clearSearchResults();
          await Future.wait([
            companyFuture,
            productFuture,
            cuidadosFuture,
            vetFuture,
            accommodationFuture
          ]);

          break;
        }
      case 1:
        {
          clearSearchResults();
          await Future.wait([companyFuture]);
          //tp = 1;

          break;
        }
      case 2:
        {
          clearSearchResults();
          await Future.wait([productFuture]);
          //tp = 2;

          break;
        }
      case 3:
        {
          clearSearchResults();
          await Future.wait([
            cuidadosFuture,
          ]);
          //tp = 3;

          break;
        }
      case 4:
        {
          clearSearchResults();
          await Future.wait([vetFuture]);
          //tp = 4;

          break;
        }
      case 5:
        {
          clearSearchResults();
          await Future.wait([accommodationFuture]);
          //tp = 4;

          break;
        }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pdt(String id) async {
    _isLoading = true;
    notifyListeners();
    // Limpa os resultados anteriores

    if (id.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Realiza as buscas em paralelo para melhor performance

    final pdtFuture = _getProduct(id);

    await Future.wait(pdtFuture as Iterable<Future>);
    _isLoading = false;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults.clear();
    _isLoading = false;
    notifyListeners(); // Notifica os listeners sobre a mudança
  }

  Future<void> _searchCompanies(String query) async {
    if (tp == 0 || tp == 1) {
      final snapshot = await _firestore
          .collection('companys')
          .where('active', isEqualTo: true)
          .where(removeDiacritics('keywords'),
              arrayContains: removeDiacritics(query).toLowerCase())
          .get();

      _searchResults.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return SearchResult(
          id: doc.id,
          name: data['name'],
          description: '',
          type: 'Fornecedor',
        );
      }));
    }
  }

  Future<void> _searchProducts(String query) async {
    if (tp == 0 || tp == 2) {
      final snapshot = await _firestore
          .collection('products')
          .where(removeDiacritics('keywords'),
              arrayContains: removeDiacritics(query).toLowerCase())
          .where('deleted', isEqualTo: false)
          .get();
      final products = await Future.wait(
        snapshot.docs.map(
          (doc) async {
            final data = doc.data();
            final companyId = data['companyID'] as String?;

            // Busca o nome da empresa
            String? companyName;
            if (companyId != null) {
              final companySnapshot =
                  await _firestore.collection('companys').doc(companyId).get();
              companyName = companySnapshot.data()?['name'] as String?;
            }

            return SearchResult(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              companyName: companyName,
              companyID: companyId,
              type: 'Produto',
            );
          },
        ),
      );

      _searchResults.addAll(products);
    }
  }

  Future<Product?> _getProduct(String id) async {
    final snapshot = await _firestore
        .collection('products')
        .where('id', isEqualTo: id)
        .get();
    await Future.wait(
      snapshot.docs.map(
        (doc) async {
          final data = doc.data();

          return Product(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              companyID: data['companyId'],
              type: 'P',
              sizes: data['sizes'],
              images: data['images'],
              categoryid: data['categoryid'],
              deleted: data['deleted']);
        },
      ),
    );
    return null;
  }

  final prodsSnapshot = <DocumentSnapshot>[];
  Product prodcs = Product();

  Future gtProduct(String ID) async {
    DocumentReference doc_ref = _firestore.collection("products").doc(ID);

    final docSnap = await doc_ref.get();
    DocumentSnapshot doc_id2 = await docSnap.reference.get();
    final prod = json.encode(doc_id2.data());
    final prodfinal = "{" '"id":' + '"' + doc_id2.id + '",' + prod.substring(1);
    return Product.fromJson(prodfinal);
  }

  Future gtSevicer(String ID) async {
    DocumentReference doc_ref = _firestore.collection("services").doc(ID);

    final docSnap = await doc_ref.get();
    DocumentSnapshot doc_id2 = await docSnap.reference.get();
    final serv = json.encode(doc_id2.data());
    final servfinal = "{" '"id":' + '"' + doc_id2.id + '",' + serv.substring(1);
    return Service.fromJson(servfinal);
  }

  Future gtHt(String ID) async {
    DocumentReference doc_ref = _firestore.collection("accommodation").doc(ID);

    final docSnap = await doc_ref.get();
    DocumentSnapshot doc_id2 = await docSnap.reference.get();
    final ht = json.encode(doc_id2.data());
    final htfinal = "{" '"id":' + '"' + doc_id2.id + '",' + ht.substring(1);
    return Accommodation.fromJson(htfinal);
  }

  Future<void> _searchCuidados(String query) async {
    if (tp == 0 || tp == 3) {
      final snapshot = await _firestore
          .collection('services')
          .where('deleted', isEqualTo: false)
          .where('type', isEqualTo: false)
          .where(removeDiacritics('keywords'),
              arrayContains: removeDiacritics(query).toLowerCase())
          .get();
      final services = await Future.wait(
        snapshot.docs.map(
          (doc) async {
            final data = doc.data();
            final companyId = data['companyID'] as String?;

            // Busca o nome da empresa
            String? companyName;
            if (companyId != null) {
              final companySnapshot =
                  await _firestore.collection('companys').doc(companyId).get();
              companyName = companySnapshot.data()?['name'] as String?;
            }

            return SearchResult(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              companyName: companyName,
              companyID: companyId,
              type: 'Cuidados',
            );
          },
        ),
      );

      _searchResults.addAll(services);
    }
  }

  Future<void> _searchVet(String query) async {
    if (tp == 0 || tp == 4) {
      final snapshot = await _firestore
          .collection('services')
          .where('deleted', isEqualTo: false)
          .where('type', isEqualTo: true)
          .where(removeDiacritics('keywords'),
              arrayContains: removeDiacritics(query).toLowerCase())
          .get();
      final services = await Future.wait(
        snapshot.docs.map(
          (doc) async {
            final data = doc.data();
            final companyId = data['companyID'] as String?;

            // Busca o nome da empresa
            String? companyName;
            if (companyId != null) {
              final companySnapshot =
                  await _firestore.collection('companys').doc(companyId).get();
              companyName = companySnapshot.data()?['name'] as String?;
            }

            return SearchResult(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              companyName: companyName,
              companyID: companyId,
              type: 'Veterinário',
            );
          },
        ),
      );

      _searchResults.addAll(services);
    }
  }

  Future<void> _searchAccommodation(String query) async {
    if (tp == 0 || tp == 5) {
      final snapshot = await _firestore
          .collection('accommodation')
          .where('deleted', isEqualTo: false)
          .where(removeDiacritics('keywords'),
              arrayContains: removeDiacritics(query).toLowerCase())
          .get();
      final accommodations = await Future.wait(
        snapshot.docs.map(
          (doc) async {
            final data = doc.data();
            final companyId = data['companyID'] as String?;

            // Busca o nome da empresa
            String? companyName;
            if (companyId != null) {
              final companySnapshot =
                  await _firestore.collection('companys').doc(companyId).get();
              companyName = companySnapshot.data()?['name'] as String?;
            }

            return SearchResult(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              companyName: companyName,
              companyID: companyId,
              type: 'Hospedagem',
            );
          },
        ),
      );

      _searchResults.addAll(accommodations);
    }
  }
}
