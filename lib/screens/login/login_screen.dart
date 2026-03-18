// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:fouryoupet/helpers/validators.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'package:provider/provider.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/page_manager.dart';
import '../../widgets/social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isObscureText = true;

  @override
  void initState() {
    isObscureText = false;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: const Text(
          'Entrar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/signup');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'CRIAR CONTA',
              style: TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () {
              _goToHome();
            },
            icon: const Icon(Icons.home, color: Colors.white),
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
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: SizedBox(
                    height: 80,
                    child: Image.asset('images/4YOUPET/logo app smal.png'),
                  ),
                ),
                const SizedBox(height: 30),
                // Formulário
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Consumer<UserManager>(
                        builder: (_, userManager, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TextFormField(
                                controller: emailController,
                                enabled: !userManager.loading,
                                decoration: const InputDecoration(
                                  hintText: 'E-mail',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (email) {
                                  if (!emailValid(email!)) {
                                    return 'e-Mail inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: passController,
                                enabled: !userManager.loading,
                                obscureText: !isObscureText,
                                decoration: InputDecoration(
                                  hintText: 'Senha',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isObscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isObscureText = !isObscureText;
                                      });
                                    },
                                  ),
                                ),
                                autocorrect: false,
                                validator: (pass) {
                                  if (pass!.isEmpty || pass.length < 6) {
                                    return 'Senha inválida';
                                  }
                                  return null;
                                },
                              ),
                              // Esqueci minha senha
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed('/resetpass');
                                  },
                                  child: const Text('Esqueci minha senha'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Botão de login tradicional
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: userManager.loading
                                      ? null
                                      : () {
                                          if (formKey.currentState!
                                              .validate()) {
                                            userManager.signIn(
                                              userapp: Userapp(
                                                email: emailController.text,
                                                password: passController.text,
                                              ),
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
                                                showTopSnackBar(
                                                  Overlay.of(context),
                                                  CustomSnackBar.success(
                                                    message:
                                                        "Sucesso ao entrar",
                                                  ),
                                                );
                                                var endereco = context
                                                        .read<UserManager>()
                                                        .userapp
                                                        ?.address
                                                        ?.length ??
                                                    0;
                                                if (endereco == 0) {
                                                  Navigator.of(context)
                                                      .pushNamed('/listadress');
                                                } else {
                                                  _goToHome();
                                                }
                                              },
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withAlpha(100),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: userManager.loading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Entrar',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Divisor
                              const SocialLoginDivider(),
                              const SizedBox(height: 16),
                              // Botões de login social
                              GoogleLoginButton(
                                isLoading: userManager.loading,
                                onPressed: () =>
                                    _handleGoogleLogin(userManager),
                              ),
                              const SizedBox(height: 10),
                              if (Platform.isIOS) ...[
                                AppleLoginButton(
                                  isLoading: userManager.loading,
                                  onPressed: () =>
                                      _handleAppleLogin(userManager),
                                ),
                                const SizedBox(height: 10),
                              ],
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGoogleLogin(UserManager userManager) {
    userManager.signInWithGoogle(
      onFail: (e) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(message: "Falha ao entrar com Google: $e"),
        );
      },
      onSuccess: () => _onLoginSuccess(),
    );
  }

  void _handleAppleLogin(UserManager userManager) {
    userManager.signInWithApple(
      onFail: (e) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(message: "Falha ao entrar com Apple: $e"),
        );
      },
      onSuccess: () => _onLoginSuccess(),
    );
  }

  void _onLoginSuccess() {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(message: "Sucesso ao entrar"),
    );
    var endereco = context.read<UserManager>().userapp?.address?.length ?? 0;
    if (endereco == 0) {
      Navigator.of(context).pushNamed('/listadress');
    } else {
      _goToHome();
    }
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
