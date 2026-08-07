// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fouryoupet/common/empty_card.dart';
import 'package:provider/provider.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/products/components/products_list_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/page_manager.dart';
import '../../models/product/product_manager.dart';
import 'components/search_dialog.dart';

class ProductsScreencp extends StatefulWidget {
  ProductsScreencp({
    Key? key,
    this.categoring,
    this.homeclic,
    this.categoria,
    this.companyid,
    required this.productManager,
  }) : super(key: key);

  final bool? categoring;
  final int? homeclic;
  final String? companyid;
  final String? categoria;
  final ProductManager productManager;

  @override
  State<ProductsScreencp> createState() => _ProductsScreencpState();
}

class _ProductsScreencpState extends State<ProductsScreencp> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.productManager.getCompanyIds();

    scrollController.addListener(scrollListener);
    widget.productManager.categoryid = widget.categoria;
    widget.productManager.companyID = widget.companyid;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Consumer<ProductManager>(builder: (_, productManager, __) {
          if (productManager.search.isEmpty) {
            return const Text('Produtos',
                style: TextStyle(color: Colors.white));
          } else {
            return LayoutBuilder(builder: (_, constraints) {
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
                ),
              );
            });
          }
        }),
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
                    if (search != null && search != "") {
                      productManager.search = search;
                    }
                  },
                );
              } else {
                return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      productManager.documentLimit = 20;
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
                  !widget.categoring! &&
                  userManager.userapp!.companyID == widget.companyid) {
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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer2<ProductManager, UserManager>(
          builder: (_, productManager, usersManager, __) {
            if (widget.categoria != null) {
              productManager.categoryid = widget.categoria;
            } else {
              productManager.categoryid = '0';
            }
            if (widget.companyid != null)
              productManager.companyID = widget.companyid;
            else
              productManager.companyID = usersManager.userapp!.companyID;

            final filteredProducts = productManager.filteredProducts;

            return Column(
              children: [
                if (filteredProducts.length > 0)
                  Expanded(
                    child: Skeletonizer(
                      enabled: productManager.loading,
                      child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredProducts.length,
                          itemBuilder: (_, index) {
                            return ProductListTile(
                              filteredProducts[index],
                              homeclic: widget.homeclic,
                            );
                          }),
                    ),
                  )
                else
                  Expanded(
                    child: productManager.loading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orangeAccent),
                            ),
                          )
                        : EmptyCard(
                            title: 'Produto não encontrado',
                            iconData: Icons.border_clear,
                          ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pushNamed('/cart');
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
