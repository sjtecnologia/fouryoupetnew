// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fouryoupet/helpers/validators.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'dart:io' show Platform;
import '../../models/page_manager.dart';
import '../../widgets/social_login_buttons.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Userapp user = Userapp();
  bool ischeched = false;
  String? referralCode; // Código de indicação

  @override
  Widget build(BuildContext context) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.white;
      }
      return Colors.orange;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Criar Conta',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _goToHome();
            },
            icon: const Icon(Icons.home, color: Colors.white),
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: formKey,
              child: Consumer<UserManager>(
                builder: (_, userManager, __) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    children: <Widget>[
                      TextFormField(
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
                        onSaved: (name) => user.name = name,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'E-mail'),
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
                        onSaved: (email) => user.email = email,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Celular (00)00000-0000'),
                        enabled: !userManager.loading,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [maskFormatter],
                        validator: (celular) {
                          if (celular!.isEmpty) return 'Campo obrigatório';

                          return null;
                        },
                        onSaved: (celular) => user.celular = celular,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'Senha'),
                        enabled: !userManager.loading,
                        obscureText: true,
                        validator: (pass) {
                          if (pass!.isEmpty) {
                            return 'Campo obrigatório';
                          } else if (pass.length < 6) {
                            return 'Senha muito curta';
                          }
                          return null;
                        },
                        onSaved: (pass) => user.password = pass,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(hintText: 'Confirmar senha'),
                        enabled: !userManager.loading,
                        obscureText: true,
                        validator: (pass) {
                          if (pass!.isEmpty) {
                            return 'Campo obrigatório';
                          } else if (pass.length < 6) {
                            return 'Senha muito curta';
                          }
                          return null;
                        },
                        onSaved: (pass) => user.confirmPassword = pass,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Código de indicação (opcional)',
                          helperText:
                              'Ganhe pontos ao ser indicado por um amigo',
                          prefixIcon: Icon(Icons.card_giftcard),
                        ),
                        enabled: !userManager.loading,
                        textCapitalization: TextCapitalization.characters,
                        onSaved: (code) => referralCode = code?.trim(),
                      ),
                      const SizedBox(
                        height: 24,
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
                            : () {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();

                                  if (user.password != user.confirmPassword) {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message: "Senhas não Coincidem",
                                      ),
                                    );
                                    return;
                                  }

                                  userManager.signUp(
                                      userapp: user,
                                      referralCode: referralCode,
                                      onSuccess: () {
                                        showTopSnackBar(
                                          Overlay.of(context),
                                          CustomSnackBar.success(
                                            message:
                                                "Cadastro concluído com sucesso",
                                          ),
                                        );
                                        //Navigator.of(context).pop();
                                        userManager.signIn(
                                            userapp: Userapp(
                                                email: user.email,
                                                password: user.password),
                                            onFail: (e) {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                CustomSnackBar.error(
                                                  message:
                                                      "Falha ao entrar: $e",
                                                ),
                                              );
                                            },
                                            onSuccess: () {
                                              // showTopSnackBar(
                                              //   Overlay.of(context),
                                              //   CustomSnackBar.success(
                                              //     message: "Sucesso ao entrar",
                                              //   ),
                                              // );
                                              if (userManager
                                                      .userapp!.address ==
                                                  null) {
                                                Navigator.of(context)
                                                    .pushNamed('/listadress');
                                              } else {
                                                Navigator.of(context).pop();
                                              }
                                            });
                                      },
                                      onFail: (e) {
                                        showTopSnackBar(
                                          Overlay.of(context),
                                          CustomSnackBar.error(
                                            message: "Falha ao cadastrar",
                                          ),
                                        );
                                      });
                                }
                              },
                        child: userManager.loading
                            ? const CircularProgressIndicator.adaptive(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Criar Conta',
                                style: TextStyle(fontSize: 15),
                              ),
                      ),
                      const SocialLoginDivider(text: 'ou cadastre-se com'),
                      // Botões de cadastro social
                      GoogleLoginButton(
                        text: 'Cadastrar com Google',
                        isLoading: userManager.loading,
                        onPressed: () {
                          userManager.signInWithGoogle(
                            onFail: (e) {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(
                                  message: "Falha ao cadastrar com Google: $e",
                                ),
                              );
                            },
                            onSuccess: () {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.success(
                                  message: "Cadastro concluído com sucesso",
                                ),
                              );
                              if (userManager.userapp!.address == null) {
                                Navigator.of(context).pushNamed('/listadress');
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      if (Platform.isIOS)
                        AppleLoginButton(
                          text: 'Cadastrar com Apple',
                          isLoading: userManager.loading,
                          onPressed: () {
                            userManager.signInWithApple(
                              onFail: (e) {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.error(
                                    message: "Falha ao cadastrar com Apple: $e",
                                  ),
                                );
                              },
                              onSuccess: () {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.success(
                                    message: "Cadastro concluído com sucesso",
                                  ),
                                );
                                if (userManager.userapp!.address == null) {
                                  Navigator.of(context)
                                      .pushNamed('/listadress');
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: !ischeched,
                            onChanged: (bool? value) {
                              setState(() {
                                userManager.setChecked(value!);
                              });
                            },
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/termlogin');
                              },
                              child: const Text(
                                'Li e Concordo com os Termos de Uso\n e Responsabilidades do\nAplicativo 4YouPet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black45,
                              )),
                        ],
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

  void _goToHome() {
    // Define a página 0 (home) no PageManager
    context.read<PageManager>().setPage(0);
    // Navega para a BaseScreen removendo todas as rotas anteriores
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/base',
      (route) => false,
    );
  }
}
