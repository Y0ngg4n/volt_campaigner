import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:volt_campaigner/utils/api/model/flyer.dart';

class FlyerApiUtils {
  static Future<FlyerRoutes?> getFlyerRoutesInDistance(
      LatLng location, double distance, String last_update) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/flyer/route/distance"),
          headers: {
            "accept": "application/json",
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "distance": distance.toString(),
            "last_update": last_update
          });
      if (response.statusCode == 200) {
        return await FlyerRoutes.fromJson(jsonDecode(response.body));
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
