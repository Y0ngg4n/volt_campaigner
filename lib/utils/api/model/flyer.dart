import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class FlyerRoute {
  String id;
  Polyline polyline;
  bool template;

  static Future<FlyerRoute> fromJson(Map<String, dynamic> json) async {
    String id = json['id'];
    Polyline polyline = await _geoJsonToPolyline(json['points']);
    bool template = json['template'];
    return FlyerRoute(id, polyline, template);
  }

  static Future<Polyline> _geoJsonToPolyline(String geoJson) async {
    GeoJSONLineString lineString = GeoJSONLineString.fromJSON(geoJson);
    List<LatLng> points = lineString.coordinates.map((e) => LatLng(e[1], e[0])).toList();
    return Polyline(points: points, color: Colors.purple, strokeWidth: 5);
  }

   FlyerRoute(this.id, this.polyline, this.template);

}

class FlyerRoutes {
  List<FlyerRoute> flyerRoutes = [];

  static Future<FlyerRoutes> fromJson(List<dynamic> json) async{
    List<FlyerRoute> flyerRoutes = [];
    for (dynamic entry in json) {
      flyerRoutes.add(await FlyerRoute.fromJson(entry.cast<String, dynamic>()));
    }
    return FlyerRoutes(flyerRoutes);
  }

  FlyerRoutes(this.flyerRoutes);
}