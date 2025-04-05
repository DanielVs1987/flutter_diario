import 'dart:async';
import 'dart:io';

import 'package:diario/screens/commom/confirmation_dialog.dart';
import 'package:diario/screens/commom/exception_dialog.dart';
import 'package:diario/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  AuthService service = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(width: 8),
          color: Colors.white,
        ),
        child: Form(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.bookmark, size: 64, color: Colors.brown),
                  const Text(
                    "Simple Journal",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "por Alura",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(thickness: 2),
                  ),
                  const Text("Entre ou Registre-se"),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(label: Text("E-mail")),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _passController,
                    decoration: const InputDecoration(label: Text("Senha")),
                    keyboardType: TextInputType.visiblePassword,
                    maxLength: 16,
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      login(context);
                    },
                    child: const Text("Continuar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  login(BuildContext context) {
    String email = _emailController.text;
    String password = _passController.text;

    service
        .login(email: email, password: password)
        .then((resultLogin) {
          if (resultLogin) {
            Navigator.pushReplacementNamed(context, "home");
          }
        })
        .catchError((error) {
          var inerErro = error as HttpException;
          showExceptionDialog(context, content: inerErro.message);
        }, test: (error) => error is HttpException)
        .catchError((error) {
          showConfirmationDialog(
            context,
            content:
                "Deseja criar um novo usuario usando o email $email e a senha inserida?",
            affirmativeOption: "CRIAR",
          ).then((value) {
            if (value != null && value) {
              service.register(email: email, password: password).then((
                resultRegister,
              ) {
                if (resultRegister) {
                  Navigator.popAndPushNamed(context, "home");
                }
              });
            }
          });
        }, test: (error) => error is UserNotFindException).catchError((error){
          showExceptionDialog(context, content: "O servidor demorou para responder tente mais tarde");
        }, test: (error) => error is TimeoutException, );
  }
}
