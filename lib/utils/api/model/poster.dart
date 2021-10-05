import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';

class PosterModel {
  String id;
  LatLng location;
  int hanging;
  PosterTagsLists posterTagsLists;
  String account;

  PosterModel(
      this.id,
      this.location,
      this.hanging,
      this.posterTagsLists,
      this.account);

  toJson() {
    Map<String, dynamic> m = new Map();
    m['id'] = id;
    m['latitude'] = location.latitude;
    m['longitude'] = location.longitude;
    m['hanging'] = hanging;
    m['poster_campaign'] = posterTagsLists.posterCampaign;
    m['poster_type'] = posterTagsLists.posterType;
    m['poster_motive'] = posterTagsLists.posterMotive;
    m['poster_target_groups'] = posterTagsLists.posterTargetGroups;
    m['poster_environment'] = posterTagsLists.posterEnvironment;
    m['poster_other'] = posterTagsLists.posterOther;
    m['account'] = account;

    return m;
  }

  PosterModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        location =
            LatLng(json['latitude'].toDouble(), json['longitude'].toDouble()),
        hanging = int.parse(json['hanging']),
        posterTagsLists = PosterTagsLists.fromJson(json),
        account = json['account'] ?? "";
}

class PosterModels {
  List<PosterModel> posterModels = [];

  toJSONEncodable() {
    return posterModels.map((item) {
      return item.toJson();
    }).toList();
  }

  PosterModels.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      posterModels.add(PosterModel.fromJson(entry.cast<String, dynamic>()));
    }
  }

  static empty() {
    return PosterModels([]);
  }

  PosterModels(this.posterModels);
}
