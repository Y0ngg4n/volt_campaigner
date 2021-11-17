import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/auth/login.dart';
import 'package:volt_campaigner/map/poster/add_poster.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/map/poster/update_poster.dart';
import 'package:volt_campaigner/utils/api/auth.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../http_utils.dart';

class PosterApiUtils {
  static Future<PosterModels?> getPostersInDistance(LatLng location,
      double distance, int hanging, String lastUpdate, String apiToken, BuildContext context) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/distance"),
          headers: {
            "accept": "application/json",
            "latitude": location.latitude.toString(),
            "longitude": location.longitude.toString(),
            "distance": distance.toString(),
            "hanging": hanging.toString(),
            "lastUpdate": lastUpdate,
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return PosterModels.fromJson(jsonDecode(response.body));
      }else if (response.statusCode == 403) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()));
      } else {
        print("Could not refresh Poster");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

  static Future<PosterModels?> getAllPosters(
      double distance, int hanging, String apiToken, BuildContext context) async {
    try {
      http.Response response = await http.get(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/all"),
          headers: {
            "accept": "application/json",
            "hanging": hanging.toString(),
            "authorization": AuthApiUtils.getBearerToken(apiToken)
          });
      if (response.statusCode == 200) {
        return PosterModels.fromJson(jsonDecode(response.body));
      }else if (response.statusCode == 403) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()));
      } else {
        print("Could not refresh Poster");
        // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

  static addPoster(
      String apiToken,
      LatLng location,
      PosterTagsLists posterTagsLists,
      OnAddPoster onAddPoster,
      BuildContext context) async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/create"),
          headers: HttpUtils.createHeader(apiToken),
          body: jsonEncode({
            'latitude': location.latitude,
            'longitude': location.longitude,
            'campaign':
                posterTagsLists.posterCampaign.map((e) => e.id).toList(),
            'postertype': posterTagsLists.posterType.map((e) => e.id).toList(),
            'motive': posterTagsLists.posterMotive.map((e) => e.id).toList(),
            'targetgroups':
                posterTagsLists.posterTargetGroups.map((e) => e.id).toList(),
            'environment':
                posterTagsLists.posterEnvironment.map((e) => e.id).toList(),
            'other': posterTagsLists.posterOther.map((e) => e.id).toList()
          }));
      if (response.statusCode == 201) {
        onAddPoster(PosterModel.fromJson(jsonDecode(response.body)));
        Navigator.pop(context);
      }else if (response.statusCode == 403) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()));
      } else {
        Messenger.showError(
            context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      Messenger.showError(
          context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }

  static updatePoster(
      String apiToken,
      PosterModel posterModel,
      PosterTagsLists posterTagsLists,
      int hanging,
      BuildContext context,
      OnUnhangPoster onUnhangPoster,
      OnUpdatePoster onUpdatePoster) async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/update"),
          headers: HttpUtils.createHeader(apiToken),
          body: jsonEncode({
            'id': posterModel.id,
            'campaign':
                posterTagsLists.posterCampaign.map((e) => e.id).toList(),
            'hanging': hanging,
            'latitude': posterModel.location.latitude,
            'longitude': posterModel.location.longitude,
            'postertype': posterTagsLists.posterType.map((e) => e.id).toList(),
            'motive': posterTagsLists.posterMotive.map((e) => e.id).toList(),
            'targetgroups':
                posterTagsLists.posterTargetGroups.map((e) => e.id).toList(),
            'environment':
                posterTagsLists.posterEnvironment.map((e) => e.id).toList(),
            'other': posterTagsLists.posterOther.map((e) => e.id).toList()
          }));
      if (response.statusCode == 201) {
        switch (hanging) {
          case 0:
            onUpdatePoster(PosterModel.fromJson(jsonDecode(response.body)));
            break;
          case 1:
            onUnhangPoster(PosterModel.fromJson(jsonDecode(response.body)));
            break;
          case 2:
            onUnhangPoster(PosterModel.fromJson(jsonDecode(response.body)));
            break;
        }
        Navigator.pop(context);
      } else if (response.statusCode == 403) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()));
      } else {
        print(response.body);
        Messenger.showError(
            context, AppLocalizations.of(context)!.errorEditPoster);
      }
    } catch (e) {
      print(e);
      Messenger.showError(
          context, AppLocalizations.of(context)!.errorEditPoster);
    }
  }
}
