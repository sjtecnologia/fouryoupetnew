import 'package:flutter/material.dart';
import 'package:fouryoupet/models/categories/categories_section.dart';
import 'package:fouryoupet/models/company/company.dart';
import 'package:provider/provider.dart';
import 'item_tile.dart';

class SectionList extends StatelessWidget {
  const SectionList(this.categoriesSection, this.company, {this.homeclic});

  final CategoriesSection categoriesSection;

  final Company? company;

  final int? homeclic;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: categoriesSection,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,

          children: <Widget>[
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Consumer<CategoriesSection>(
                builder: (_, categoriesSection, __) {
                  return GridView.count(
                    primary: true,
                    crossAxisCount: 1,
                    shrinkWrap: true,
                    children: <Widget>[
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: categoriesSection.items!.length,
                        itemBuilder: (_, index) {
                          if (index < categoriesSection.items!.length) {
                            return ItemTile(
                                categoriesSection.items![index], company,
                                homeclic: homeclic);
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
