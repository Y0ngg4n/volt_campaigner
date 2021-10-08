import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../http_utils.dart';

class AuthApiUtils {
  static Future<String?> getJWT(String accessToken) async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/login"),
          headers: {"content-type": "application/json",
            "accept": "application/json",},
          body: jsonEncode({
      "auth_token": getBearerToken(accessToken)
      }));
    if (response.statusCode == 201) {
    Map<String, dynamic> json = jsonDecode(response.body);
    return json['token'];
    }
    } catch (e) {
    print(e);
    }
  }

  static getBearerToken(String apiToken){
    return 'Bearer ' + apiToken;
  }
}