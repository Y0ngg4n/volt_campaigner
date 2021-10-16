import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:volt_campaigner/utils/api/model/area.dart';
import 'package:volt_campaigner/utils/api/model/flyer.dart';

import 'auth.dart';

class AreaApiUtils {
  static Future<Areas?> getAreaInDistance(LatLng location, double distance,
      String last_update, String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/area/distance"),
          headers: {
            "accept": "application/json",
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "distance": distance.toString(),
            "last_update": last_update,
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return await Areas.fromJson(jsonDecode(response.body));
      } else {
        print("Could not refresh Areas");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

  static Future<Areas?> getAreaContains(LatLng location,
      String last_update, String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/area/contains"),
          headers: {
            "accept": "application/json",
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "last_update": last_update,
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return await Areas.fromJson(jsonDecode(response.body));
      } else {
        print("Could not refresh Area Contains");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

  static Future<Areas?> getAllAreas(String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/area/contains"),
          headers: {
            "accept": "application/json",
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return await Areas.fromJson(jsonDecode(response.body));
      } else {
        print(response.body);
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

  static Future<ContainsAreaLimits?> getAreaContainsLimits(LatLng location,
      String last_update, String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/area/contains-limits"),
          headers: {
            "accept": "application/json",
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "last_update": last_update,
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return ContainsAreaLimits.fromJson(jsonDecode(response.body));
      } else {
        print("Could not get Area Contains Limits");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }


  static Future deleteArea(String id, String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/area/delete"),
          headers: {
            "accept": "application/json",
            "id": id,
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
      } else {
        print("Could not delete Areas");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }
}
