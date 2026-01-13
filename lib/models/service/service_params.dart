import 'package:flutter/material.dart';
import 'package:fouryoupet/models/categories/categories_section_item.dart';
import 'package:fouryoupet/models/company/company.dart';

class ServiceParams extends ChangeNotifier {
  String? companyid;
  String? categoryid;
  int? homeclic;

  ServiceParams.fromtotal(Company company,
      CategoriesSectionItem categoriesSectionItem, int homeclic) {
    companyid = company.id;
    categoryid = categoriesSectionItem.pos;
    homeclic = homeclic;
  }
}
