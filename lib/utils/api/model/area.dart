import 'package:latlong2/latlong.dart';
import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AreaModel {
  String id;
  String name;
  Polygon points;
  int maxPoster;

  AreaModel(this.id, this.name, this.points, this.maxPoster);

  static Future<AreaModel> fromJson(Map<String, dynamic> json) async {
    String id = json['id'];
    String name = json['name'];
    Polygon polyline = await _geoJsonToPolyline(json['points']);
    int maxPoster = int.parse(json['max_poster']);
    return AreaModel(id, name,  polyline, maxPoster);
  }

  static Future<Polygon> _geoJsonToPolyline(String geoJson) async {
    GeoJSONPolygon polygon = GeoJSONPolygon.fromJSON(geoJson);
    List<LatLng> points = [];
    for(List<List<double>> polygonCoordinates in polygon.coordinates){
      for(List<double> coordinate in polygonCoordinates){
        points.add(LatLng(coordinate[1], coordinate[0]));
      }
    }
    return Polygon(
        points: points,
        borderColor: Colors.purple,
        borderStrokeWidth: 5,
        color: Color.fromARGB(50, 255, 0, 0));
  }
}

class Areas {
  List<AreaModel> areas = [];

  static Future<Areas> fromJson(List<dynamic> json) async {
    List<AreaModel> areas = [];
    for (dynamic entry in json) {
      areas.add(await AreaModel.fromJson(entry.cast<String, dynamic>()));
    }
    return Areas(areas);
  }

  Areas(this.areas);
}
