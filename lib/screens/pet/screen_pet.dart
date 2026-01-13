import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:flutter/material.dart';

import 'package:fouryoupet/screens/pet/components/search_dialog.dart';
import 'package:provider/provider.dart';

import '../../common/empty_card.dart';
import '../../common/login_card.dart';
import '../../models/page_manager.dart';
import '../../models/pet/pet_manager.dart';
import '../../models/user/user_manager.dart';

import 'components/pets_list_tile.dart';

class ScreenPet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Consumer<PetManager>(
          builder: (_, petManager, __) {
            if (petManager.search.isEmpty) {
              return const Text('Meus Pets',
                  style: TextStyle(color: Colors.white));
            } else {
              return LayoutBuilder(builder: (_, constraints) {
                return GestureDetector(
                  onTap: () async {
                    final search = await showDialog<String>(
                        context: context,
                        builder: (_) => SearchDialog(petManager.search));
                    if (search != null) {
                      petManager.search = search;
                    }
                  },
                  child: Container(
                      width: constraints.biggest.width,
                      child: Text(
                        petManager.search,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )),
                );
              });
            }
          },
        ),
        automaticallyImplyLeading: true, // Ativa o botão do menu lateral
        centerTitle: true,
        actions: <Widget>[
          Consumer<PetManager>(
            builder: (_, petManager, __) {
              if (petManager.search.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final search = await showDialog<String>(
                        context: context,
                        builder: (_) => SearchDialog(petManager.search));
                    if (search != null) {
                      petManager.search = search;
                    }
                  },
                );
              } else {
                return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      petManager.search = '';
                    });
              }
            },
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed('/edit_pet');
              context.read<PetManager>().pets.clear();
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
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
        child: Consumer2<PetManager, UserManager>(
          builder: (_, petManager, usersManager, __) {
            if (usersManager.isLoggedIn) {
              final filteredPets =
                  petManager.findPetByUser(usersManager.userapp!.id);
              if (!usersManager.isLoggedIn) {
                return LoginCard();
              }
              if (filteredPets.isEmpty) {
                return const EmptyCard(
                  title: 'Nenhum Pet encontrado',
                  iconData: Icons.border_clear,
                );
              }
              return ListView.builder(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top,
                  ),
                  itemCount: filteredPets.length,
                  itemBuilder: (_, index) {
                    return PetListTile(
                      filteredPets[index],
                    );
                  });
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
