// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

//import '../../common/custom_drawer/custom_drawer.dart';

import '../../helpers/empty_card.dart';
import '../../models/page_manager.dart';

// ignore: must_be_immutable
class AddresssScreen extends StatefulWidget {
  AddresssScreen({this.type});
  String? type;
  @override
  State<AddresssScreen> createState() => _AddresssScreenState();
}

class _AddresssScreenState extends State<AddresssScreen> {
  Address? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Drawer removido para evitar múltiplos Drawers empilhados
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Endereços', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading:
            true, // Mostra o botão do menu se houver Drawer
        actions: <Widget>[
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              if (userManager.userapp?.address != null) {
                final checkedAddresses = userManager.userapp!.address!
                    .where((a) => a.checked == true);
                if (checkedAddresses.isNotEmpty) {
                  selectedAddress = checkedAddresses.last;
                }
              }
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  if (userManager.userapp != null) {
                    userManager.editing = true;
                    await Navigator.of(context)
                        .pushNamed('/addadress', arguments: Address());
                  } else {
                    await Navigator.of(context).pushNamed('/login');
                  }
                },
              );
            },
          )
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
        child: Consumer<UserManager>(
          builder: (_, usersManager, __) {
            if (usersManager.loading) {
              return Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                ),
              );
            }
            String title;
            if (usersManager.userapp == null) {
              title =
                  'Você precisar estar logado para visualizar ou cadastrar seus endereços!';
            } else {
              title =
                  'Nenhum endereço encontrado, favor cadastrar um endereço para continuar utilizando o 4YouPet!';
            }

            if (usersManager.userapp?.address != null) {
              return ListView.builder(
                  itemCount: usersManager.userapp?.address?.length,
                  itemBuilder: (_, index) {
                    return Card(
                      child: RadioListTile<Address?>(
                        value: usersManager.userapp!.address![index],
                        groupValue: selectedAddress,
                        isThreeLine: false,
                        secondary: Visibility(
                          visible:
                              !usersManager.userapp!.address![index].checked!,
                          child: IconButton(
                            onPressed: () {
                              usersManager.removeAddress(
                                  usersManager.userapp!.address![index]);
                            },
                            icon: Icon(Icons.remove),
                          ),
                          replacement: IconButton(
                              onPressed: () async {
                                usersManager.editing = true;
                                await Navigator.of(context).pushNamed(
                                    '/addadress',
                                    arguments:
                                        usersManager.userapp!.address![index]);
                                usersManager.editing = false;
                              },
                              icon: Icon(
                                Icons.edit,
                              )),
                        ),
                        title: Text(
                            '${usersManager.userapp!.address![index].street}'),
                        subtitle: usersManager
                                        .userapp!.address![index].complement ==
                                    null ||
                                usersManager
                                    .userapp!.address![index].complement!
                                    .trim()
                                    .isEmpty
                            ? Text('Nº ' +
                                '${usersManager.userapp!.address![index].number}' +
                                ' - ' +
                                '${usersManager.userapp!.address![index].city}' +
                                ' - ' +
                                '${usersManager.userapp!.address![index].state}')
                            : Text('Nº ' +
                                '${usersManager.userapp!.address![index].number}' +
                                ' - ${usersManager.userapp!.address![index].complement}' +
                                ' - ' +
                                '${usersManager.userapp!.address![index].city}' +
                                ' - ' +
                                '${usersManager.userapp!.address![index].state}'),
                        onChanged: (value) {
                          setState(
                            () {
                              upadress(context).then(
                                (vl) => {
                                  if (vl == true)
                                    {
                                      selectedAddress = value,
                                      for (var i = 0;
                                          i <
                                              usersManager
                                                  .userapp!.address!.length;
                                          i++)
                                        {
                                          if (selectedAddress ==
                                              usersManager.userapp!.address![i])
                                            {
                                              usersManager.userapp!
                                                  .setCheckedAddress(true, i),
                                              usersManager.userapp!.address![i]
                                                  .checked = true
                                            }
                                          else
                                            {
                                              usersManager.userapp!
                                                  .setCheckedAddress(false, i),
                                              usersManager.userapp!.address![i]
                                                  .checked = false
                                            }
                                        },
                                    },
                                  if (widget.type == 'c')
                                    {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/address')
                                    }
                                  else
                                    Navigator.of(context).pop()
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  });
            } else {
              return EmptyCard(
                title: title,
                // 'Nenhum endereço encontrado, favor cadastrar um endereço para continuar utilizando o 4YouPet!',
                iconData: Icons.border_clear,
              );
            }
          },
        ),
      ),
    );
  }

  Future upadress(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text('Confirma alteração de endereço de entrega?'),
        title: Text('Confirmação'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Sim'),
          ),
        ],
      ),
    );
  }
}
