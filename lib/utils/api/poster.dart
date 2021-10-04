import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../http_utils.dart';

class PosterApiUtils {
  static Future<PosterModels?> getPointsInDistance(LatLng location, double distance, bool hanging) async {

    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/distance"),
          headers: {
            "accept": "application/json",
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "distance": distance.toString(),
            "hanging": hanging.toString()
          });
      if (response.statusCode == 200) {
        return PosterModels.fromJson(jsonDecode(response.body));
      } else {
        print("Could not refresh Poster");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }


}
