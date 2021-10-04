import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';

class PosterModel {
  String id;
  LatLng location;
  bool hanging;
  List<PosterTag> posterType;
  List<PosterTag> posterMotive;
  List<PosterTag> posterTargetGroups;
  List<PosterTag> posterEnvironment;
  List<PosterTag> posterOther;

  PosterModel(
      this.id,
      this.location,
      this.hanging,
      this.posterType,
      this.posterMotive,
      this.posterTargetGroups,
      this.posterEnvironment,
      this.posterOther);

  toJson() {
    Map<String, dynamic> m = new Map();
    m['id'] = id;
    m['latitude'] = location.latitude;
    m['longitude'] = location.longitude;
    m['hanging'] = hanging;
    m['poster_type'] = posterType;
    m['poster_motive'] = posterMotive;
    m['poster_target_groups'] = posterTargetGroups;
    m['poster_environment'] = posterEnvironment;
    m['poster_other'] = posterOther;

    return m;
  }

  PosterModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        location =
            LatLng(json['latitude'].toDouble(), json['longitude'].toDouble()),
        hanging = json['hanging'],
        posterType = PosterTags.fromJson(json['poster_type']).posterTags,
        posterMotive = PosterTags.fromJson(json['motive']).posterTags,
        posterTargetGroups =
            PosterTags.fromJson(json['target_groups']).posterTags,
        posterEnvironment = PosterTags.fromJson(json['environment']).posterTags,
        posterOther = PosterTags.fromJson(json['other']).posterTags;
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
