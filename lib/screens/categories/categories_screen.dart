import 'package:flutter/material.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/models/categories/categories_manager.dart';
import 'package:fouryoupet/models/company/company.dart';

import 'package:provider/provider.dart';

import '../../models/page_manager.dart';

import 'components/section_list.dart';

class CategoriesScreen extends StatelessWidget {
  final Company? company;
  final int? homeclic;

  const CategoriesScreen({Key? key, this.company, this.homeclic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomDrawer();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Categorias',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                  height:
                      kToolbarHeight + MediaQuery.of(context).padding.top - 16),
            ),
            Consumer<CategoriesManager>(
              builder: (_, categoriesManager, __) {
                if (categoriesManager.loading) {
                  return const SliverToBoxAdapter(
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      backgroundColor: Colors.transparent,
                    ),
                  );
                }
                final List<Widget> children =
                    categoriesManager.sections.map<Widget>((section) {
                  switch (section.type) {
                    case 'List':
                      return SectionList(
                        section,
                        company,
                        homeclic: homeclic,
                      );
                    default:
                      return Container();
                  }
                }).toList();
                return SliverList(
                  delegate: SliverChildListDelegate(children),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
