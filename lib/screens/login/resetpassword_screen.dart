// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

import 'package:fouryoupet/helpers/validators.dart';

import 'package:provider/provider.dart';

import 'package:fouryoupet/models/user/user_manager.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _email = '';
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Recuparar Senha'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                height: 150,
                width: 150,
                child: Image.asset('images/4YOUPET/logo app smal.png'),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: formKey,
                  child: Consumer<UserManager>(
                    builder: (_, userManager, child) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        children: <Widget>[
                          TextFormField(
                            controller: emailController,
                            enabled: !userManager.loading,
                            decoration:
                                const InputDecoration(hintText: 'E-mail'),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              setState(() {
                                _email = value;
                              });
                            },
                            autocorrect: false,
                            validator: (email) {
                              if (!emailValid(email!)) {
                                return 'e-Mail inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            child: const Text(
                              'Solicitar Senha',
                              style: TextStyle(fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.center,
                              backgroundColor: primaryColor,
                            ),
                            onPressed: userManager.loading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      userManager.resetpassord(
                                          emailController.text, onFail: (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              Text('Falha ao enviar email: $e'),
                                          backgroundColor: Colors.red,
                                        ));
                                      }, onSuccess: () {
                                        Navigator.of(context).pop();
                                      }, emailAddress: emailController.text);
                                    }
                                  },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
