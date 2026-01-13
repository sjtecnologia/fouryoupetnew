import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import '../../common/empty_card.dart';
import '../../common/login_card.dart';
import '../../models/page_manager.dart';
import '../../models/pet/pet.dart';
import '../../models/pet/pet_manager.dart';
import 'components/pets_list_tile.dart';
import 'components/search_dialog.dart';

// ignore: must_be_immutable
class PetsScreen extends StatelessWidget {
  PetsScreen();

  List<Pet> filteredPet = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Consumer<PetManager>(
          builder: (_, petManager, __) {
            if (petManager.search.isEmpty) {
              return const Text('Pets', style: TextStyle(color: Colors.white));
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
                  child: Text(
                    petManager.search,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              });
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
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
                  color: Colors.white,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    petManager.search = '';
                  },
                  color: Colors.white,
                );
              }
            },
          ),
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
            color: Colors.white,
          ),
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.of(context).pushNamed(
                    '/edit_pet',
                  );
                },
                color: Colors.white,
              );
            },
          )
        ],
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
        child: Consumer2<PetManager, UserManager>(
            builder: (_, petManager, usersManager, __) {
          filteredPet =
              petManager.findPetByUser(usersManager.userapp!.id.toString());
          if (!usersManager.isLoggedIn) {
            return LoginCard();
          }
          if (filteredPet.isEmpty) {
            return const EmptyCard(
              title: 'Nenhum Pet encontrado',
              iconData: Icons.border_clear,
            );
          }
          return ListView.builder(
            itemCount: filteredPet.length,
            itemBuilder: (_, index) {
              return PetListTile(
                  filteredPet[index], usersManager.userapp?.id.toString());
            },
          );
        }),
      ),
    );
  }
}
