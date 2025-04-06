import 'dart:convert';
import 'dart:io';

import 'package:diario/services/webclient.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
http.Client client = WebClient().client;
String url = WebClient.url;

  Future<bool> login({required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse("${url}login"),
      body: {"email": email, "password": password},
    );

    if (response.statusCode != 200) {
      String content = json.decode(response.body);
      switch (content) {
        case "Cannot find user":
          throw UserNotFindException();
      }

      throw HttpException(response.body);
    }

    saveUsersInfos(response.body);

    return true;
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    http.Response response = await client.post(
      Uri.parse("${url}register"),
      body: {"email": email, "password": password},
    );
    if (response.statusCode != 201) {
      throw HttpException(response.body);
    }

    saveUsersInfos(response.body);
    return true;
  }

  saveUsersInfos(String body) async {
    Map<String, dynamic> infos = json.decode(body);

    String token = infos["accessToken"];
    String email = infos["user"]["email"];
    int id = infos["user"]["id"];

    //print("$token\n$email\n$id");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("accessToken", token);
    prefs.setString("email", email);
    prefs.setInt("id", id);

    //String? tokenSalvo = prefs.getString("email");

  }
}

class UserNotFindException implements Exception {}
