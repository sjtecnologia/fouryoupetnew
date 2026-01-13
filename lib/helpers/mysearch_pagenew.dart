import 'package:flutter/material.dart';
import 'package:fouryoupet/models/accommodation/accommodation.dart';

import 'package:provider/provider.dart';

import 'package:fouryoupet/models/Search/search_provider.dart';
//import 'package:toggle_switch/toggle_switch.dart';

import '../common/custom_drawer/custom_drawer.dart';
import '../models/page_manager.dart';
import '../models/user/user_manager.dart';

import '../screens/hotel/add_ht.dart';
import 'debouncer.dart';

class MySearchPageNew extends StatefulWidget {
  @override
  State<MySearchPageNew> createState() => _MySearchPageNewState();

  MySearchPageNew({
    Key? key,
  }) : super(key: key);
}

class _MySearchPageNewState extends State<MySearchPageNew> {
  final debouncer = Debouncer(milliseconds: 500);
  bool firstSwicthValue = false;
  var autoCompleteText = '';
  bool visibility = false;
  String hintsearch = 'Buscar em todo 4YouPet...';

  //SearchProvider? searchProvider;

  final TextEditingController _searchController = TextEditingController();
  int _type = 0;

  @override
  void dispose() {
    _searchController.dispose();
    //Provider.of<SearchProvider>(context, listen: false).clearSearchResults();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).clearSearchResults();
    });
    _searchController.addListener(
      () {
        debouncer(() {
          // Realiza a busca quando o texto muda
          Provider.of<SearchProvider>(context, listen: false)
              .search(_searchController.text, _type);
        });
      },
    );
    super.initState();
  }

  void processAutoComplete(String text) {
    setState(() {
      autoCompleteText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight =
        MediaQuery.of(context).size.height - kToolbarHeight - 30;
    CustomDrawer();
    return Scaffold(
        extendBodyBehindAppBar: true,
        drawer: CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text('Pesquisa', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: <Widget>[
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
          child: Column(
            children: [
              SizedBox(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: TextField(
                      showCursor: true,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 161, 0),
                      ),
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.search,
                            color: Color.fromARGB(255, 255, 161, 0)),
                        focusColor: Color.fromARGB(255, 255, 161, 0),
                        hoverColor: Color.fromARGB(255, 255, 161, 0),
                        hintText: hintsearch,
                        hintStyle: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 35.0, right: 35.0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color.fromARGB(255, 255, 111, 0),
                          ),
                          onPressed: () {
                            hintsearch = 'Buscar os produtos...';
                            _searchController.clear();
                            Provider.of<SearchProvider>(context, listen: false)
                                .clearSearchResults();
                            _type = 2;
                          },
                          child: Image.asset(
                            'images/4YOUPET/shop.png',
                            height: screenHeight / 9,
                            // width: screenWidth / 1, //80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color.fromARGB(255, 255, 111, 0),
                          ),
                          onPressed: () {
                            hintsearch = 'Buscar os cuidados...';
                            _searchController.clear();
                            Provider.of<SearchProvider>(context, listen: false)
                                .clearSearchResults();
                            _type = 3;
                          },
                          child: Image.asset(
                            'images/4YOUPET/cut.png',
                            height: screenHeight / 9,
                            // width: screenWidth / 1, //80,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 35.0, right: 35.0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color.fromARGB(255, 255, 111, 0),
                          ),
                          onPressed: () {
                            hintsearch = 'Buscar os serviços veterinários...';
                            _searchController.clear();
                            Provider.of<SearchProvider>(context, listen: false)
                                .clearSearchResults();
                            _type = 4;
                          },
                          child: Image.asset(
                            'images/4YOUPET/VET_1.png',
                            height: screenHeight / 9,
                            // width: screenWidth / 1, //80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color.fromARGB(255, 255, 111, 0),
                          ),
                          onPressed: () {
                            hintsearch = 'Buscar as hospedagens...';
                            _searchController.clear();
                            Provider.of<SearchProvider>(context, listen: false)
                                .clearSearchResults();
                            _type = 5;
                          },
                          child: Image.asset(
                            'images/4YOUPET/HOTEL_12.png',
                            height: screenHeight / 9,
                            // width: screenWidth / 1, //80,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 35.0, right: 35.0, top: 10),
                    child: Container(
                      width: screenWidth,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromARGB(255, 255, 111, 0),
                        ),
                        onPressed: () {
                          hintsearch = 'Buscar em todo 4YouPet...';
                          _searchController.clear();
                          Provider.of<SearchProvider>(context, listen: false)
                              .clearSearchResults();
                          _type = 0;
                        },
                        child: Text(
                          'Geral',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Resultados da Pesquisa',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Consumer<SearchProvider>(
                  builder: (context, searchProvider, _) {
                    // if (searchProvider.searchResults.isEmpty &&
                    //     _searchController.text.isEmpty) {
                    //   return Center(child: Text('Faça sua pesquisa...'));
                    // } else

                    if (searchProvider.searchResults.isEmpty &&
                        _searchController.text.isNotEmpty) {
                      if (searchProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      } else
                        //Future.delayed(Duration(microseconds: 1000));
                        return Container();
                      //Center(child: Text('Nenhum resultado encontrado'));
                    } else {
                      searchProvider.searchResults
                          .sort((a, b) => a.name.compareTo(b.name));
                      return ListView.builder(
                        itemCount: searchProvider.searchResults.length,
                        itemBuilder: (context, index) {
                          final result = searchProvider.searchResults[index];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                leading: Text(
                                  result.type,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                title: Text(
                                  result.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (result.description != null)
                                      Text(result.description!),
                                    if (result.companyName !=
                                        null) // Exibe apenas se houver companyName
                                      Text(
                                        result.companyName!.toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () async {
                                  if (result.type == 'Produto') {
                                    var product =
                                        await Provider.of<SearchProvider>(
                                                context,
                                                listen: false)
                                            .gtProduct(result.id);

                                    Navigator.of(context).pushNamed(
                                        '/productcp',
                                        arguments: product);
                                  }
                                  if (result.type == 'Cuidados' ||
                                      result.type == 'Veterinário') {
                                    var service =
                                        await Provider.of<SearchProvider>(
                                                context,
                                                listen: false)
                                            .gtSevicer(result.id);

                                    Navigator.of(context).pushNamed(
                                        '/servicecp',
                                        arguments: service);
                                  }
                                  if (result.type == 'Hospedagem') {
                                    Accommodation hospedagem =
                                        await Provider.of<SearchProvider>(
                                                context,
                                                listen: false)
                                            .gtHt(result.id);

                                    if (context
                                        .read<UserManager>()
                                        .isLoggedIn) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AddHt(
                                                    company:
                                                        hospedagem.companyID,
                                                    homeclic: int.parse(
                                                        hospedagem.categoryid!),
                                                    accommodation: hospedagem,
                                                  )));
                                    } else {
                                      Navigator.of(context).pushNamed('/login');
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
