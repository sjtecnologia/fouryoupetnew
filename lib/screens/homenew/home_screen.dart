import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';

import 'package:fouryoupet/models/banner/banner_manager.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/product/product.dart';
import 'package:fouryoupet/models/product/product_manager.dart';

import 'package:fouryoupet/models/user/user_manager.dart';

import 'package:provider/provider.dart';

import 'package:transparent_image/transparent_image.dart';

import 'package:local_auth/local_auth.dart';

import '../companys/companys_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _cachedProducts = [];
  bool _loadingCache = true;

  void _showMaterialDialog(int arg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Localização'),
            content: Text(
                'O 4YouPet necessita da sua localização enquanto o aplicativo esta aberto, para poder localizar os PetShops mais próximos e lhe mostrar no mapa!, não ultilizamos sua localização quando o aplicativo esta fechado '),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanysScreen(
                        homeclic: arg,
                        //companyManager: context.read<CompanyManager>(),
                      ),
                    ),
                  );
                  //Navigator.of(context).pushNamed(nav, arguments: arg);
                },
                child: Text("OK"),
              )
            ],
          );
        });
  }

  Future<void> _loadFeaturedProducts() async {
    if (!mounted) return;
    setState(() => _loadingCache = true);

    try {
      // Carregar apenas 20 produtos aleatórios para a home (muito mais rápido!)
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('deleted', isEqualTo: false)
          .limit(20)
          .get();

      if (!mounted) return;

      _cachedProducts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Embaralhar para variedade
      _cachedProducts.shuffle();
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingCache = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<BannerManager>().banners;
    _loadFeaturedProducts();
    // Carregar empresas para mostrar o nome do fornecedor e produtos para navegação
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyManager>().loadAllCompanys();
      context.read<ProductManager>().fetchNextProds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 111, 0),
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Image(
            height: 85,
            width: 85,
            image: AssetImage('images/4YOUPET/logo app smal.png'),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamed('/cart'),
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer3<UserManager, BannerManager, ProductManager>(
            builder: (_, userManager, bannerManager, productManager, __) {
          List<Widget> columnChildren = [];

          // Se o usuário está logado, mostra o botão de endereço
          if (userManager.userapp != null &&
              userManager.userapp!.address != null &&
              userManager.userapp!.address!
                  .where((a) => a.checked == true)
                  .isNotEmpty) {
            columnChildren.add(
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.location_on, color: Colors.white),
                  label: Text(
                    (() {
                      final address = userManager.userapp!.address!
                          .where((a) => a.checked == true)
                          .last;
                      if (address.complement == null ||
                          address.complement!.trim().isEmpty) {
                        return '${address.street}, ${address.number}';
                      } else {
                        return '${address.street}, ${address.number} - ${address.complement}';
                      }
                    })(),
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 111, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/listadress');
                  },
                ),
              ),
            );
          } else if (userManager.userapp == null) {
            // Se o usuário NÃO está logado, mostra botão de biometria ou login
            columnChildren.add(
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                child: FutureBuilder<bool>(
                  future: userManager.isBiometricsAvailable(),
                  builder: (context, snapshot) {
                    final canUseBiometrics = snapshot.data ?? false;

                    if (canUseBiometrics) {
                      // Mostra botão de login com biometria (ícone/label dinâmico)
                      return FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          userManager.getSavedEmail(),
                          userManager.getAvailableBiometricType(),
                        ]),
                        builder: (context, snapshot) {
                          final savedEmail = snapshot.data?[0] as String?;
                          final biometricType =
                              snapshot.data?[1] as BiometricType?;
                          final isFace = biometricType == BiometricType.face;
                          return ElevatedButton.icon(
                            icon: Icon(isFace ? Icons.face : Icons.fingerprint,
                                color: Colors.white, size: 24),
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFace
                                      ? 'Entrar com Face ID'
                                      : 'Entrar com Impressão Digital',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (savedEmail != null && savedEmail.isNotEmpty)
                                  Text(
                                    savedEmail,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 76, 175, 80),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                            ),
                            onPressed: () async {
                              // Salva referência ao ScaffoldMessenger antes da operação assíncrona
                              final messenger = ScaffoldMessenger.of(context);

                              // Fazer login com biometria
                              await userManager.signInWithBiometrics(
                                onSuccess: () {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Login realizado com sucesso!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                onFail: (error) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(error.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    } else {
                      // Mostra botão simples de login
                      return ElevatedButton.icon(
                        icon: Icon(Icons.login, color: Colors.white),
                        label: Text(
                          'Entrar na sua conta',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 111, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/login');
                        },
                      );
                    }
                  },
                ),
              ),
            );
          }
          // Debug: quantidade de produtos carregados
          // columnChildren.add(
          //   Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 8.0),
          //     child: Column(
          //       children: [
          //         Text(
          //           'DEBUG INFO:',
          //           style: TextStyle(
          //               color: Colors.yellow,
          //               fontSize: 14,
          //               fontWeight: FontWeight.bold),
          //           textAlign: TextAlign.center,
          //         ),
          //         Text(
          //           'Produtos em cache: ${_cachedProducts.length}',
          //           style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold),
          //           textAlign: TextAlign.center,
          //         ),
          //         Text(
          //           'Loading: $_loadingCache',
          //           style: TextStyle(color: Colors.white, fontSize: 14),
          //           textAlign: TextAlign.center,
          //         ),
          //         if (_cachedProducts.isNotEmpty)
          //           Text(
          //             'Primeiro produto: ${_cachedProducts.first['name'] ?? "sem nome"}',
          //             style: TextStyle(color: Colors.white, fontSize: 12),
          //             textAlign: TextAlign.center,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //       ],
          //     ),
          //   ),
          // );
          // Carousel otimizado (carrega apenas 20 produtos)
          columnChildren.add(
            Builder(
              builder: (context) {
                final promoProducts = _cachedProducts.take(10).toList();

                // Mostrar loading enquanto carrega
                if (promoProducts.isEmpty && _loadingCache) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Carregando produtos...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (promoProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Nenhum produto disponível no momento.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                }
                return CarouselSlider(
                  options: CarouselOptions(
                    initialPage: 0,
                    viewportFraction: 0.9,
                    aspectRatio: 16 / 9,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5),
                    enableInfiniteScroll: true,
                    height: screenHeight * .30,
                  ),
                  items: promoProducts.map<Widget>((productData) {
                    final images = productData['images'] as List?;
                    final imageUrl = (images != null && images.isNotEmpty)
                        ? images.first as String?
                        : null;

                    return Consumer<CompanyManager>(
                      builder: (_, companyManager, __) {
                        final companyId = productData['companyID'] as String?;
                        final company = companyId != null
                            ? companyManager.findCompanyByID(companyId)
                            : null;

                        return Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth * .13,
                              right: screenWidth * .13),
                          child: GestureDetector(
                            onTap: () async {
                              // Navegar para detalhes do produto
                              final productId = productData['id'] as String?;
                              debugPrint('🔍 Clicou no produto ID: $productId');
                              if (productId != null) {
                                // Primeiro tenta buscar na lista carregada
                                var product =
                                    productManager.findProductByID(productId);

                                // Se não encontrou, busca diretamente do Firestore
                                if (product == null) {
                                  debugPrint(
                                      '🔄 Produto não está na lista, buscando do Firestore...');
                                  try {
                                    final doc = await FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(productId)
                                        .get();

                                    if (doc.exists) {
                                      product = Product.fromDocument(doc);
                                      debugPrint(
                                          '✅ Produto carregado do Firestore: ${product.name}');
                                    }
                                  } catch (e) {
                                    debugPrint('❌ Erro ao buscar produto: $e');
                                  }
                                }

                                if (product != null) {
                                  debugPrint(
                                      '✅ Navegando para produto: ${product.name}');
                                  Navigator.of(context).pushNamed('/productcp',
                                      arguments: product);
                                } else {
                                  debugPrint('❌ Produto não encontrado');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Produto não disponível no momento'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8)),
                                        child: (imageUrl != null &&
                                                imageUrl.trim().isNotEmpty)
                                            ? FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image: imageUrl,
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                imageErrorBuilder: (context,
                                                    error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                        Icons.broken_image,
                                                        size: 48,
                                                        color: Colors.grey),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                child: Icon(Icons.image,
                                                    size: 48,
                                                    color: Colors.grey),
                                              ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(8, 6, 8, 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          productData['name'] as String? ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Builder(
                                          builder: (context) {
                                            // Calcular o menor preço dos sizes (como no Product.basePrice)
                                            final sizes =
                                                productData['sizes'] as List?;
                                            if (sizes != null &&
                                                sizes.isNotEmpty) {
                                              num? lowestPrice;
                                              for (final size in sizes) {
                                                final price =
                                                    size['price'] as num?;
                                                if (price != null) {
                                                  if (lowestPrice == null ||
                                                      price < lowestPrice) {
                                                    lowestPrice = price;
                                                  }
                                                }
                                              }
                                              if (lowestPrice != null) {
                                                return Text(
                                                  'R\$ ${lowestPrice.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            }
                                            return SizedBox.shrink();
                                          },
                                        ),
                                        (company != null)
                                            ? Text(
                                                'Loja: ${company.name ?? ''}',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 80, 80, 80),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          );
          // Add main action buttons and rest of the column
          columnChildren.add(
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, top: 20, right: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * .35,
                            height: MediaQuery.of(context).size.height * .15,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: Color.fromARGB(255, 255, 111, 0),
                                    width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                await context
                                    .read<CompanyManager>()
                                    .getPosicao();
                                var lp =
                                    context.read<CompanyManager>().lpermissao;
                                if (lp == "denied" &&
                                    (Theme.of(context).platform ==
                                        TargetPlatform.android)) {
                                  _showMaterialDialog(1);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompanysScreen(homeclic: 1),
                                    ),
                                  );
                                }
                              },
                              child: Image.asset(
                                'images/4YOUPET/shop.png',
                                height: screenHeight / 7,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(right: 10, top: 20, left: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * .35,
                            height: MediaQuery.of(context).size.height * .15,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: Color.fromARGB(255, 255, 111, 0),
                                    width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                await context
                                    .read<CompanyManager>()
                                    .getPosicao();
                                var lp =
                                    context.read<CompanyManager>().lpermissao;
                                if (lp == "denied" &&
                                    (Theme.of(context).platform ==
                                        TargetPlatform.android)) {
                                  _showMaterialDialog(2);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompanysScreen(homeclic: 2),
                                    ),
                                  );
                                }
                              },
                              child: Image.asset(
                                'images/4YOUPET/cut.png',
                                height: screenHeight / 7,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 20, right: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * .35,
                            height: MediaQuery.of(context).size.height * .15,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: Color.fromARGB(255, 255, 111, 0),
                                    width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                await context
                                    .read<CompanyManager>()
                                    .getPosicao();
                                var lp =
                                    context.read<CompanyManager>().lpermissao;
                                if (lp == "denied" &&
                                    (Theme.of(context).platform ==
                                        TargetPlatform.android)) {
                                  _showMaterialDialog(3);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompanysScreen(homeclic: 3),
                                    ),
                                  );
                                }
                              },
                              child: Image.asset(
                                'images/4YOUPET/VET_1.png',
                                height: screenHeight / 7,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 10, top: 20, left: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * .35,
                            height: MediaQuery.of(context).size.height * .15,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: Color.fromARGB(255, 255, 111, 0),
                                    width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                await context
                                    .read<CompanyManager>()
                                    .getPosicao();
                                var lp =
                                    context.read<CompanyManager>().lpermissao;
                                if (lp == "denied" &&
                                    (Theme.of(context).platform ==
                                        TargetPlatform.android)) {
                                  _showMaterialDialog(4);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompanysScreen(homeclic: 4),
                                    ),
                                  );
                                }
                              },
                              child: Image.asset(
                                'images/4YOUPET/HOTEL_12.png',
                                height: screenHeight / 7,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          columnChildren.add(SizedBox(height: 32));
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: columnChildren,
            ),
          );
// Removed duplicate main action buttons section
        }),
      ),
    );
  }
}
