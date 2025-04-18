import 'package:flutter/material.dart';

Future<dynamic> showConfirmationDialog(
  BuildContext context, {
  String title = "Atenção!",
  String content = "Você realmente deseja executar essa operção?",
  String affirmativeOption = "Confirmar",
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context, false);
          }, child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(
              affirmativeOption.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
