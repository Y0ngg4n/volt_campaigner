import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

typedef OnPositionChanged = Function(CenterOnLocationUpdate);
typedef OnRefresh = Function();
typedef OnMarkerTap = Function(Marker);

class MapSettings {
  static getMapOptions(
      OnPositionChanged onPositionChanged, LatLng currentPosition) {
    return MapOptions(
        center: currentPosition,
        zoom: 17.0,
        plugins: [
          MarkerClusterPlugin(),
        ],
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if (hasGesture) onPositionChanged(CenterOnLocationUpdate.never);
        });
  }

  static getTileLayerWidget(){
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c'],
      ),
    );
  }

  static getRefreshFab(BuildContext context, OnPositionChanged onPositionChanged, StreamController<double> _userPositionStreamController, OnRefresh onRefresh, bool refreshing){
    return FloatingActionButton(
      heroTag: "Center-FAB",
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        onPositionChanged(CenterOnLocationUpdate.always);
        // Automatically center the location marker on the map when location updated until user interact with the map.
        // Center the location marker on the map and zoom the map to level 18.
        _userPositionStreamController.add(18);
        onRefresh();
      },
      child: refreshing
          ? CircularProgressIndicator()
          : Icon(
        Icons.my_location,
        color: Colors.white,
      ),
    );
  }

  static getMarkerClusterLayerOptions(OnMarkerTap onMarkerTap, List<Marker> markers) {
    return MarkerClusterLayerOptions(
      onMarkerTap: (marker) => onMarkerTap(marker),
      size: Size(40, 40),
      fitBoundsOptions: FitBoundsOptions(
        padding: EdgeInsets.all(50),
      ),
      markers: markers,
      polygonOptions: PolygonOptions(
          borderColor: Colors.blueAccent,
          color: Colors.black12,
          borderStrokeWidth: 3),
      builder: (context, markers) {
        return FloatingActionButton(
          child: Text(markers.length.toString()),
          onPressed: null,
        );
      },
    );
  }
}
