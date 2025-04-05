import 'dart:io';

import 'package:diario/helpers/logout.dart';
import 'package:diario/screens/commom/exception_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/weekday.dart';
import '../../models/journal.dart';
import '../../services/journal_service.dart';

class AddJournalScreen extends StatelessWidget {
  final Journal journal;
  final bool isEditing;
  AddJournalScreen({super.key, required this.journal, required this.isEditing});

  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _contentController.text = journal.content;

    return Scaffold(
      appBar: AppBar(
        title: Text(WeekDay(journal.createdAt).toString()),
        actions: [
          IconButton(
            onPressed: () {
              registerJournal(context);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          maxLines: null,
          minLines: null,
        ),
      ),
    );
  }

  registerJournal(BuildContext context) async {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken");
      if (token != null) {
        JournalService journalService = JournalService();
        journal.content = _contentController.text;
        if (isEditing) {
          journalService
              .register(journal, token)
              .then((value) {
                if (value) {
                  Navigator.pop(context, DisposeStatus.success);
                } else {
                  Navigator.pop(context, DisposeStatus.error);
                }
              })
              .catchError((error) {
                logout(context);
              }, test: (error) => error is TokenNotValidException)
              .catchError((error) {
                var inerErro = error as HttpException;
                showExceptionDialog(context, content: inerErro.message);
              }, test: (error) => error is HttpException);
        } else {
          journalService
              .edit(journal, journal.id, token)
              .then((value) {
                if (value) {
                  Navigator.pop(context, DisposeStatus.success);
                } else {
                  Navigator.pop(context, DisposeStatus.error);
                }
              })
              .catchError((error) {
                logout(context);
              }, test: (error) => error is TokenNotValidException)
              .catchError((error) {
                var inerErro = error as HttpException;
                showExceptionDialog(context, content: inerErro.message);
              }, test: (error) => error is HttpException);
        }
      }
    });
  }
}

enum DisposeStatus { exit, error, success }
