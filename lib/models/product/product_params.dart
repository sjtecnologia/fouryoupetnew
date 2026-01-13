import 'package:flutter/material.dart';
import 'package:fouryoupet/models/categories/categories_section_item.dart';
import 'package:fouryoupet/models/company/company.dart';


class ProductParams extends ChangeNotifier{


  String? companyid;
  String? categoryid;

  ProductParams.fromtotal(Company company, CategoriesSectionItem categoriesSectionItem){
    companyid = company.id;
    categoryid = categoriesSectionItem.pos;
  }

//   ProductParams.fromCompany(this._company){
//      companyid = company.id;
//   }
//
//   Company _company = Company();
//   Company get company => _company;
//   set company(Company value){
//     _company = value;
//     notifyListeners();
//   }
//
//   ProductParams.fromCategory(this._category){
//     categoryid = category.pos;
//   }
//
//   CategoriesSectionItem _category = CategoriesSectionItem();
//   CategoriesSectionItem get category => _category;
//   set category(CategoriesSectionItem value){
//     _category = value;
//     notifyListeners();
//   }
//
// void setCategoryid(CategoriesSectionItem value){
//    categoryid = value.pos;
//   }


}