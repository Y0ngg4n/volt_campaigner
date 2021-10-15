import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/utils/api/auth.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../http_utils.dart';

class PosterTagApiUtils {

  static Future<PosterTags?> getAllPosterTags(String url, String apiToken) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster-tags/" + url),
          headers: {
            "accept": "application/json",
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return PosterTags.fromJsonAll(jsonDecode(response.body));
      } else {
        print("Could not refresh Poster-Tags");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

}
