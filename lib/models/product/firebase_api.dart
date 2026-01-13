import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/iterables.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseApi {
  static Future<QuerySnapshot> getProducts(
    int limit,
    String companyID,
    String categoryid, {
    DocumentSnapshot? startAfter,
  }) async {
    final refProducts = FirebaseFirestore.instance
        .collection('products')
        .where('deleted', isEqualTo: false)
        .where('companyID', isEqualTo: companyID)
        .where('categoryid', isEqualTo: categoryid)
        .orderBy('name')
        .limit(limit);

    if (startAfter == null) {
      return refProducts.get();
    } else {
      return refProducts.startAfterDocument(startAfter).get();
    }
  }

  static Future<QuerySnapshot> getProductID(
    int limit,
    String ID,
  ) async {
    final refProducts = FirebaseFirestore.instance
        .collection('products')
        .where("documentId", isEqualTo: ID);

    return refProducts.get();
  }

  static Future<QuerySnapshot> getProductanycatcp(
    int limit,
    String companyID, {
    DocumentSnapshot? startAfter,
  }) async {
    final refProducts = FirebaseFirestore.instance
        .collection('products')
        .where('deleted', isEqualTo: false)
        .where('companyID', isEqualTo: companyID)
        .orderBy('name')
        .limit(limit);

    if (startAfter == null) {
      return refProducts.get();
    } else {
      return refProducts.startAfterDocument(startAfter).get();
    }
  }

  static Future<QuerySnapshot> getProductcpall(
    String companyID,
    String categoryid, {
    DocumentSnapshot? startAfter,
  }) async {
    var refProducts;
    if (categoryid != "0") {
      refProducts = FirebaseFirestore.instance
          .collection('products')
          .where('deleted', isEqualTo: false)
          .where('companyID', isEqualTo: companyID)
          .where('categoryid', isEqualTo: categoryid)
          .orderBy('name');
    } else {
      refProducts = FirebaseFirestore.instance
          .collection('products')
          .where('deleted', isEqualTo: false)
          .where('companyID', isEqualTo: companyID)
          .orderBy('name');
    }

    if (startAfter == null) {
      return refProducts.get();
    } else {
      return refProducts.startAfterDocument(startAfter).get();
    }
  }

  static Future<List<QueryDocumentSnapshot>> getProductanycatandcp(
    List<String> vcompany, {
    DocumentSnapshot? startAfter,
  }) async {
    final vcomp = partition(vcompany, 10);

    final querySnapshots = await Future.wait(vcomp.map((chunk) {
      Query itemsQuery = FirebaseFirestore.instance
          .collection('products')
          .where('deleted', isEqualTo: false)
          .where('companyID', whereIn: chunk)
          .orderBy('name');
      return itemsQuery.get();
    }).toList());
    // ignore: unnecessary_null_comparison
    return querySnapshots == null
        ? []
        : await Stream.fromIterable(querySnapshots)
            .flatMap((qs) => Stream.fromIterable(qs.docs))
            .toList();
  }

  static Future<List<QueryDocumentSnapshot>> getProductanycpcat(
    int limit,
    List<String> vcompany,
    String categoryid, {
    DocumentSnapshot? startAfter,
  }) async {
    final vcomp = partition(vcompany, 10);
    final querySnapshots = await Future.wait(vcomp.map((chunk) {
      Query itemsQuery = FirebaseFirestore.instance
          .collection('products')
          .where('deleted', isEqualTo: false)
          .where('categoryid', isEqualTo: categoryid)
          .where('companyID', whereIn: chunk)
          .orderBy('name');

      return itemsQuery.get();
    }).toList());
    // ignore: unnecessary_null_comparison
    return querySnapshots == null
        ? []
        : await Stream.fromIterable(querySnapshots)
            .flatMap((qs) => Stream.fromIterable(qs.docs))
            .toList();
  }
}
