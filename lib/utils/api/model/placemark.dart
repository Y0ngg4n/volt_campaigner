import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';

class PlacemarkModel {
  String id;
  String title;
  String description;
  LatLng location;
  int type;
  String account;

  PlacemarkModel(this.id, this.title, this.description, this.location,
      this.type, this.account);

  toJson() {
    Map<String, dynamic> m = new Map();
    m['id'] = id;
    m['title'] = title;
    m['description'] = description;
    m['latitude'] = location.latitude;
    m['longitude'] = location.longitude;
    m['type'] = type;
    m['account'] = account;

    return m;
  }

  PlacemarkModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        title = json['title'] ?? "",
        description = json['description'] ?? "",
        location =
            LatLng(json['latitude'].toDouble(), json['longitude'].toDouble()),
        type = int.parse(json['type'] ?? "0"),
        account = json['account'] ?? "";
}

class PlacemarkModels {
  List<PlacemarkModel> placemarkModels = [];

  toJson() {
    return placemarkModels.map((item) {
      return item.toJson();
    }).toList();
  }

  PlacemarkModels.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      placemarkModels.add(PlacemarkModel.fromJson(entry.cast<String, dynamic>()));
    }
  }

  static empty() {
    return PlacemarkModels([]);
  }

  PlacemarkModels(this.placemarkModels);
}
