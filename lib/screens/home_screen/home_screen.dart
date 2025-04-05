import 'dart:io';

import 'package:diario/helpers/logout.dart';
import 'package:diario/screens/commom/exception_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/journal.dart';
import '../../services/journal_service.dart';
import 'widgets/home_screen_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;

  // A base de dados mostrada na lista
  Map<String, Journal> database = {};

  final ScrollController _listScrollController = ScrollController();
  final JournalService _journalService = JournalService();

  int? userId;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título basado no dia atual
        title: Text(
          "${currentDay.day}  |  ${currentDay.month}  |  ${currentDay.year}",
        ),
        actions: [
          IconButton(
            onPressed: () {
              refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                logout(context);
              },
              title: Text("Sair"),
              leading: Icon(Icons.logout),
            ),
          ],
        ),
      ),
      body:
          userId != null
              ? ListView(
                controller: _listScrollController,
                children: generateListJournalCards(
                  windowPage: windowPage,
                  currentDay: currentDay,
                  database: database,
                  refreshFunction: refresh,
                  userId: userId!,
                ),
              )
              : Center(child: CircularProgressIndicator()),
    );
  }

  void refresh() {
    SharedPreferences.getInstance()
        .then((prefs) {
          String? token = prefs.getString("accessToken");
          String? email = prefs.getString("email");
          int? id = prefs.getInt("id");

          if (token != null && email != null && id != null) {
            setState(() {
              userId = id;
            });

            _journalService.getAll(id: id.toString(), token: token).then((
              List<Journal> listJournal,
            ) {
              setState(() {
                database = {};
                for (Journal journal in listJournal) {
                  database[journal.id] = journal;
                }

                if (_listScrollController.hasClients) {
                  final double position =
                      _listScrollController.position.maxScrollExtent;
                  _listScrollController.jumpTo(position);
                }
              });
            });
          } else {
            Navigator.pushReplacementNamed(context, "login");
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
