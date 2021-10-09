import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../http_utils.dart';

class AuthApiUtils {
  static Future<String?> getJWT(String accessToken) async {
    try {
      http.Response response =
          await http.post(Uri.parse((dotenv.env['REST_API_URL']!) + "/login"),
              headers: {
                "content-type": "application/json",
                "accept": "application/json",
              },
              body: jsonEncode({"auth_token": accessToken}));
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        return json['token'];
      }
    } catch (e) {
      print(e);
    }
  }

  static getBearerToken(String apiToken) {
    return 'Bearer ' + apiToken;
  }

  static Future<String?> getVolunteerToken(String apiToken) async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/volunteer-login"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'authorization': AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        return json['token'];
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> validate(String apiToken) async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/validate"),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            'authorization': AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
