import 'package:flutter/material.dart';
import 'package:fouryoupet/common/custom_drawer/custom_drawer.dart';
import 'package:fouryoupet/helpers/login_card.dart';
import 'package:fouryoupet/helpers/validators.dart';
import 'package:fouryoupet/models/user/user_manager.dart';

import 'package:fouryoupet/screens/users/components/celular_field.dart';

import 'package:fouryoupet/screens/users/components/cpf_field.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/page_manager.dart';

class UserScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Dados da Conta',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<UserManager>().delete();
              context.read<PageManager>().setPage(0);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
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
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: formKey,
              child: Consumer<UserManager>(
                builder: (_, userManager, __) {
                  if (userManager.userapp == null) {
                    return Container(
                      width: 300,
                      height: 260,
                      child: LoginCard(),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    children: <Widget>[
                      TextFormField(
                        initialValue: userManager.userapp!.name,
                        decoration: const InputDecoration(
                          hintText: 'Nome Completo',
                        ),
                        enabled: !userManager.loading,
                        validator: (name) {
                          if (name!.isEmpty) {
                            return 'Campo obrigatório';
                          } else if (name.trim().split(' ').length <= 1) {
                            return 'Preencha seu Nome completo';
                          }
                          return null;
                        },
                        onSaved: (name) =>
                            userManager.userapp!.name = name ?? '',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'E-mail'),
                        initialValue: userManager.userapp!.email,
                        enabled: !userManager.loading,
                        keyboardType: TextInputType.emailAddress,
                        validator: (email) {
                          if (email!.isEmpty) {
                            return 'Campo obrigatório';
                          } else if (!emailValid(email)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                        onSaved: (email) =>
                            userManager.userapp!.email = email ?? '',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CelularField(),
                      const SizedBox(
                        height: 16,
                      ),
                      CpfField(),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Theme.of(context).primaryColor.withAlpha(100),
                        ),
                        onPressed: userManager.loading
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();

                                  // Salva os dados no Firestore
                                  userManager.loading = true;
                                  try {
                                    await userManager.userapp!.saveData();
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.success(
                                        message: "Dados salvos com sucesso!",
                                      ),
                                    );
                                    // Atualiza o PageManager para página 0 (Home) antes de navegar
                                    context.read<PageManager>().setPage(0);
                                    Navigator.of(context).pushNamed('/');
                                  } catch (e) {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message: "Erro ao salvar dados: $e",
                                      ),
                                    );
                                  } finally {
                                    userManager.loading = false;
                                  }
                                }
                              },
                        child: userManager.loading
                            ? const CircularProgressIndicator.adaptive(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Salvar dados conta',
                                style: TextStyle(fontSize: 15),
                              ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
