import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../http_utils.dart';
import '../messenger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NomatimApiUtils {
  static Future<NomatimSearchLocations> search(
      String search, BuildContext context, String apiToken) async {
    try {
      http.Response response = await http.post(
          Uri.parse("https://nominatim.openstreetmap.org/search.php?q=" +
              search +
              "&format=json"),
          headers: HttpUtils.createHeader(apiToken),
          body: jsonEncode({'q': search, 'format': 'json'}));
      if (response.statusCode == 200) {
        return NomatimSearchLocations.fromJson(jsonDecode(response.body));
      } else {
        Messenger.showError(
            context, AppLocalizations.of(context)!.errorAddPoster);
        return NomatimSearchLocations([]);
      }
    } catch (e) {
      print(e);
      Messenger.showError(
          context, AppLocalizations.of(context)!.errorAddPoster);
      return NomatimSearchLocations([]);
    }
  }
}

class NomatimSearchLocation {
  int placeId;
  String licence;
  String osmType;
  int osmId;
  List<double> boundingBox;
  double latitude;
  double longitude;
  String displayName;
  String classString;
  String typeString;
  double importance;
  String icon;

  static List<double> fromDoubleList(List<dynamic> json) {
    List<double> list = [];
    for (dynamic entry in json) {
      list.add(double.parse(entry));
    }
    return list;
  }

  NomatimSearchLocation.fromJson(Map<String, dynamic> json)
      : placeId = json['place_id'] ?? 0,
        licence = json['licence'] ?? "",
        osmType = json['osm_type'] ?? "",
        osmId = json['osm_id'] ?? 0,
        boundingBox =
            NomatimSearchLocation.fromDoubleList(json['boundingbox'] ?? []),
        latitude = double.parse(json['lat'] ?? "0"),
        longitude = double.parse(json['lon'] ?? "0"),
        displayName = json['display_name'] ?? "",
        classString = json['class'] ?? "",
        typeString = json['type'] ?? "",
        importance = json['importance'] ?? 0,
        icon = json['icon'] ?? "";

  @override
  String toString() {
    return '$displayName';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NomatimSearchLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => hashValues(latitude, longitude);
}

class NomatimSearchLocations {
  List<NomatimSearchLocation> locations = [];

  NomatimSearchLocations.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      locations.add(NomatimSearchLocation.fromJson(entry));
    }
  }

  NomatimSearchLocations(this.locations);
}
