import 'dart:convert';
import 'dart:io';
import 'package:diario/services/webclient.dart';

import 'package:http/http.dart' as http;

import '../models/journal.dart';

class JournalService {
  static const String resource = "journals/";
  http.Client client = WebClient().client;
  String url = WebClient.url;

  String getURL() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }

  Future<bool> register(Journal journal, String token) async {
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.post(
      getUri(),
      headers: {
        'Content-type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: journalJSON,
    );

    if (response.statusCode != 201) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }

      throw HttpException(response.body);
    }

    return true;
  }

  Future<bool> edit(Journal journal, String id, String token) async {
    journal.updatedAt = DateTime.now();
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.put(
      Uri.parse("${getURL()}$id"),
      headers: {
        'Content-type': 'application/json',
        "Authorization": "Bearer $token",
      },
      body: journalJSON,
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }

    return true;
  }

  Future<List<Journal>> getAll({
    required String id,
    required String token,
  }) async {
    http.Response response = await client.get(
      Uri.parse("${url}users/$id/$resource"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }

    List<Journal> result = [];

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonMap in jsonList) {
      result.add(Journal.fromMap(jsonMap));
    }

    return result;
  }

  Future<bool> delete(String id, String token) async {
    http.Response response = await http.delete(
      Uri.parse("${getURL()}$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }

      throw HttpException(response.body);
    }

    return true;
  }
}

class TokenNotValidException implements Exception {}
