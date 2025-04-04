import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal.dart';
import 'http_interceptors.dart';

class JournalService {
  static const String url = "http://192.168.0.8:3000/";
  static const String resource = "journals/";

  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  String getURL() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }

  Future<bool> register(Journal journal) async {
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.post(
      getUri(),
      headers: {'Content-type': 'application/json'},
      body: journalJSON,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<bool> edit(Journal journal, String id) async {
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.put(
      Uri.parse("${getURL()}$id"),
      headers: {'Content-type': 'application/json'},
      body: journalJSON,
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<Journal>> getAll({required String id, required String token}) async {
    http.Response response = await client.get(Uri.parse("${url}users/$id/$resource"), headers: {
      "Authorization": "Bearer $token"

    });

    if (response.statusCode != 200) {
      //TODO: Criar uma exceção personalizada
      throw Exception();
    }

    List<Journal> result = [];

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonMap in jsonList) {
      result.add(Journal.fromMap(jsonMap));
    }

    return result;
  }

  Future<bool> tokenExpired({required String id, required String token}) async {
    http.Response response = await client.get(Uri.parse("${url}users/$id/$resource"), headers: {
      "Authorization": "Bearer $token"
    });

    if(response.statusCode == 401){
      return true;
    }
    return false;
  }

  Future<bool> delete(String id) async {
    http.Response response = await http.delete(Uri.parse("${getURL()}$id"));

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

}



