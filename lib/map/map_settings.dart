import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:volt_campaigner/drawer.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnPositionChanged = Function(CenterOnLocationUpdate);
typedef OnRefresh = Function();
typedef OnMarkerTap = Function(Marker);
typedef OnZoomChange = Function(double);
typedef OnTap = Function();

class MapSettings {
  static getMapOptions(double zoom, OnPositionChanged onPositionChanged,
      LatLng currentPosition, OnTap? onTap) {
    return MapOptions(
        onTap: (_, _s) {
          if (onTap != null) onTap();
        },
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

  static getRefreshFab(BuildContext context,
      OnPositionChanged onPositionChanged,
      StreamController<double> _userPositionStreamController,
      OnRefresh onRefresh,
      bool refreshing) {
    return DescribedFeatureOverlay(
      featureId: 'refresh',
      tapTarget: Icon(Icons.my_location),
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      targetColor: Theme
          .of(context)
          .primaryColor,
      title: Text(AppLocalizations.of(context)!.featureRefresh),
      description:
      Text(AppLocalizations.of(context)!.featureRefreshDescription),
      child: FloatingActionButton(
        heroTag: "Center-FAB",
        backgroundColor: Theme
            .of(context)
            .primaryColor,
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
      ),
    );
  }

  static getMarkerClusterLayerOptions(OnMarkerTap onMarkerTap,
      List<Marker> markers) {
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

  static getDrawerFab(BuildContext context, String? photoUrl,
      OnDrawerOpen onDrawerOpen) {
    return DescribedFeatureOverlay(
        featureId: 'drawer_menu',
        tapTarget: Icon(Icons.menu),
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        targetColor: Theme
            .of(context)
            .primaryColor,
        title: Text(AppLocalizations.of(context)!.addPoster),
        description:
        Text(AppLocalizations.of(context)!.featureAddPosterDescription),
        child: SizedBox(
          height: 75,
          width: 75,
          child: FloatingActionButton(
              heroTag: "Drawer-FAB",
              backgroundColor: Theme
                  .of(context)
                  .primaryColor,
              onPressed: () {
                onDrawerOpen();
              },
              child: Container(
                  child: photoUrl == null
                      ? CircleAvatar(minRadius: 35, child: Icon(Icons.menu))
                      : CircleAvatar(
                    minRadius: 35,
                    backgroundImage: Image
                        .network(photoUrl)
                        .image,
                  ))),
        ));
  }

  static getZoomPlusButton(BuildContext context, double zoom,
      OnZoomChange onZoomChange) {
    const double zoomFactor = 0.5;
    return DescribedFeatureOverlay(
      featureId: 'zoomIn',
      tapTarget: Icon(Icons.add),
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      targetColor: Theme
          .of(context)
          .primaryColor,
      title: Text(AppLocalizations.of(context)!.featureZoomIn),
      description: Text(AppLocalizations.of(context)!.featureZoomInDescription),
      child: FloatingActionButton(
          heroTag: "Zoom-Plus-FAB",
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          onPressed: () {
            onZoomChange(zoom + zoomFactor);
          },
          child: Icon(Icons.add, color: Colors.white)),
    );
  }

  static getZoomMinusButton(BuildContext context, double zoom,
      OnZoomChange onZoomChange) {
    const double zoomFactor = 0.5;
    return DescribedFeatureOverlay(
      featureId: 'zoomOut',
      tapTarget: Icon(Icons.remove),
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      targetColor: Theme
          .of(context)
          .primaryColor,
      title: Text(AppLocalizations.of(context)!.featureZoomOut),
      description:
      Text(AppLocalizations.of(context)!.featureZoomOutDescription),
      child: FloatingActionButton(
          heroTag: "Zoom-Minus-FAB",
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          onPressed: () {
            onZoomChange(zoom - zoomFactor);
          },
          child: Icon(Icons.remove, color: Colors.white)),
    );
  }
}
