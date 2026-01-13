// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/products/components/products_list_tile.dart';

import '../../models/page_manager.dart';
import '../../models/product/product_manager.dart';
import 'components/search_dialog.dart';

class ProductsScreen extends StatefulWidget {
  ProductsScreen({
    Key? key,
    this.categoring,
    this.homeclic,
    this.companyid,
    required this.productManager,
  }) : super(key: key);

  final bool? categoring;
  final int? homeclic;
  final String? companyid;
  final ProductManager productManager;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final scrollController = ScrollController();
  //ProductParams? productParams;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(scrollListener);

    widget.productManager.companyID = widget.companyid;

    widget.productManager.prodcs.clear();
    widget.productManager.prodsSnapshot.clear();
    widget.productManager.fetchNextProds();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      if (widget.productManager.hasNext) {
        widget.productManager.fetchNextProds();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 111, 0),
        iconTheme: IconThemeData(color: Colors.white),
        title: Consumer<ProductManager>(
          builder: (_, productManager, __) {
            if (productManager.search.isEmpty) {
              if (productManager.loading) {
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                  ),
                );
              } else {
                return const Text('Produtos',
                    style: TextStyle(color: Colors.white));
              }
            } else {
              return GestureDetector(
                onTap: () async {
                  final search = await showDialog<String>(
                      context: context,
                      builder: (_) => SearchDialog(productManager.search));
                  if (search != null) {
                    productManager.search = search;
                  }
                },
                child: Text(
                  productManager.search,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          Consumer<ProductManager>(
            builder: (_, productManager, __) {
              if (productManager.search.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final search = await showDialog<String>(
                        context: context,
                        builder: (_) => SearchDialog(productManager.search));
                    if (search != null) {
                      productManager.search = search;
                    }
                  },
                );
              } else {
                return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      productManager.search = '';
                    });
              }
            },
          ),
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              if (userManager.adminEnabled &&
                  (widget.categoring == false || widget.categoring == null) &&
                  userManager.userapp?.companyID != null &&
                  userManager.userapp?.companyID == widget.companyid) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/edit_product',
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 111, 0),
            Color.fromARGB(255, 255, 161, 0),
            //Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Consumer2<ProductManager, UserManager>(
          builder: (_, productManager, usersManager, __) {
            productManager.categoryid = '0';
            productManager.companyID = usersManager.userapp!.companyID;

            final filteredProducts = productManager.filteredProducts;

            if (filteredProducts.length > 0)
              return ListView.builder(
                  controller: scrollController,
                  itemCount: filteredProducts.length,
                  itemBuilder: (_, index) {
                    return ProductListTile(
                      filteredProducts[index],
                      homeclic: widget.homeclic,
                    );
                  });
            return Container();
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   foregroundColor: Theme.of(context).primaryColor,
      //   onPressed: () {
      //     Navigator.of(context).pushNamed('/cart');
      //   },
      //   child: const Icon(Icons.shopping_cart),
      // ),
    );
  }
}
