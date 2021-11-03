import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:volt_campaigner/drawer.dart';

typedef OnPositionChanged = Function(CenterOnLocationUpdate);
typedef OnRefresh = Function();
typedef OnMarkerTap = Function(Marker);
typedef OnZoomChange = Function(double);

class MapSettings {
  static getMapOptions(double zoom, OnPositionChanged onPositionChanged,
      LatLng currentPosition) {
    return MapOptions(
        maxZoom: 19,
        minZoom: 1,
        center: currentPosition,
        zoom: zoom,
        plugins: [
          MarkerClusterPlugin(),
        ],
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if (hasGesture) onPositionChanged(CenterOnLocationUpdate.never);
        });
  }

  static getTileLayerWidget() {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c'],
      ),
    );
  }

  static getRefreshFab(
      BuildContext context,
      OnPositionChanged onPositionChanged,
      StreamController<double> _userPositionStreamController,
      OnRefresh onRefresh,
      bool refreshing) {
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

  static getMarkerClusterLayerOptions(
      OnMarkerTap onMarkerTap, List<Marker> markers) {
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

  static getDrawerFab(
      BuildContext context, String? photoUrl, OnDrawerOpen onDrawerOpen) {
    return SizedBox(
      height: 75,
      width: 75,
      child: FloatingActionButton(
          heroTag: "Drawer-FAB",
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            onDrawerOpen();
          },
          child: Container(
              child: photoUrl == null
                  ? CircleAvatar(minRadius: 35, child: Icon(Icons.menu))
                  : CircleAvatar(
                      minRadius: 35,
                      backgroundImage: Image.network(photoUrl).image,
                    ))),
    );
  }

  static getZoomPlusButton(
      BuildContext context, double zoom, OnZoomChange onZoomChange) {
    const double zoomFactor = 1;
    return FloatingActionButton(
        heroTag: "Zoom-Plus-FAB",
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          if (zoom + zoomFactor < 19) onZoomChange(zoom + zoomFactor);
        },
        child: Icon(Icons.add, color: Colors.white));
  }

  static getZoomMinusButton(
      BuildContext context, double zoom, OnZoomChange onZoomChange) {
    const double zoomFactor = 1;
    return FloatingActionButton(
        heroTag: "Zoom-Minus-FAB",
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          if (zoom - zoomFactor > 0) onZoomChange(zoom - zoomFactor);
        },
        child: Icon(Icons.remove, color: Colors.white));
  }
}
