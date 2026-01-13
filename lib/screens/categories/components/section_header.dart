import 'package:flutter/material.dart';
import 'package:fouryoupet/models/categories/categories_section.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final section = context.watch<CategoriesSection>();
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          section.name ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      );
    }

}
