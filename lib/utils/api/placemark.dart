import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/utils/api/auth.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../http_utils.dart';
import 'model/placemark.dart';

class PlacemarkApiUtils {
  static Future<PlacemarkModels?> getPlacemarksInDistance(
      LatLng location,
      double distance,
      String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/placemark/distance"),
          headers: {
            "accept": "application/json",
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "distance": distance.toString(),
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return PlacemarkModels.fromJson(jsonDecode(response.body));
      } else {
        print("Could not refresh Placemarks");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

  static Future<PlacemarkModels?> getAllPlacemarks(
      String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/placemark/all"),
          headers: {
            "accept": "application/json",
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return PlacemarkModels.fromJson(jsonDecode(response.body));
      } else {
        print("Could not refresh Placemark");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }
}
