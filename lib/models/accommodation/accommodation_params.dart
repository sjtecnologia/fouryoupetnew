import 'package:flutter/material.dart';
import 'package:fouryoupet/models/categories/categories_section_item.dart';
import 'package:fouryoupet/models/company/company.dart';

class AccommodationParams extends ChangeNotifier {
  String? companyid;
  String? categoryid;
  int? homeclic;

  AccommodationParams.fromtotal(Company company,
      CategoriesSectionItem categoriesSectionItem, int homeclic) {
    companyid = company.id;
    categoryid = categoriesSectionItem.pos;
    this.homeclic = homeclic;
  }
}
