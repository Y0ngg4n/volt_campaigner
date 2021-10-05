import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/map/poster/add_poster.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/map/poster/update_poster.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart'
    show PopupOptions;
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef OnLocationUpdate = Function(LatLng);
typedef OnRefresh = Function();

class PosterMapView extends StatefulWidget {
  PosterModels posterInDistance;
  LatLng currentPosition;
  OnLocationUpdate onLocationUpdate;
  OnRefresh onRefresh;
  PosterTagsLists posterTagsLists;

  PosterMapView({
    Key? key,
    required this.posterInDistance,
    required this.currentPosition,
    required this.onLocationUpdate,
    required this.onRefresh,
    required this.posterTagsLists,
  }) : super(key: key);

  @override
  _PosterMapViewState createState() => _PosterMapViewState();
}

class _PosterMapViewState extends State<PosterMapView> {
  // Set default location to Volt Headquarter
  Map<Marker, PosterModel> markers = {};
  Map<Polyline, List<LatLng>> polylines = {};
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _userPositionStreamController;
  late StreamSubscription<Position> _currentPositionStreamSubscription;
  late SharedPreferences prefs;
  bool drawNearestPosterLine = false;

  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _userPositionStreamController = StreamController<double>();

    _currentPositionStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      setState(() => widget
          .onLocationUpdate(LatLng(position.latitude, position.longitude)));
    });
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          drawNearestPosterLine =
              (prefs.get(SharedPrefsSlugs.drawNearestPosterLine) ??
                  drawNearestPosterLine) as bool;
        }));
  }

  Widget build(BuildContext context) {
    _addPosterMarker();
    _addPolylines();
    return Stack(children: [
      FlutterMap(
        children: [
          TileLayerWidget(
            options: TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              maxZoom: 25,
            ),
          ),
          LocationMarkerLayerWidget(
            plugin: LocationMarkerPlugin(
              centerCurrentLocationStream: _userPositionStreamController.stream,
              centerOnLocationUpdate: _centerOnLocationUpdate,
            ),
          ),
        ],
        options: _getMapOptions(),
        layers: [
          _getPolyLineLayerOptions(),
          _getMarkerClusterLayerOptions(),
        ],
        nonRotatedLayers: [],
      ),
      Positioned(right: 20, top: 20, child: _getRefreshFab()),
      Positioned(right: 20, bottom: 20, child: _getAddPosterFab())
    ]);
  }

  _addPosterMarker() {
    setState(() {
      markers.clear();
      for (PosterModel posterModel in widget.posterInDistance.posterModels) {
        Marker marker = Marker(
          anchorPos: AnchorPos.exactly(Anchor(25, 5)),
          // Offset by experimentation, (0,25) should work as well
          rotateOrigin: Offset(0, 20),
          width: 50,
          height: 50,
          rotate: true,
          point: posterModel.location,
          builder: (ctx) => Icon(Icons.location_pin, size: 50),
        );
        markers[marker] = posterModel;
      }
    });
  }

  _addPolylines() {
    setState(() {
      polylines.clear();
      // Add Polyline to nearest
      if (drawNearestPosterLine) {
        List<LatLng> points = [widget.currentPosition];
        double shortestDistance = double.maxFinite;
        PosterModel? nearest;
        for (PosterModel posterModel in widget.posterInDistance.posterModels) {
          if (Distance()
                  .distance(widget.currentPosition, posterModel.location) <
              shortestDistance) {
            nearest = posterModel;
          }
        }
        if (nearest != null) {
          points.add(nearest.location);
          polylines[Polyline(
              points: points, strokeWidth: 4.0, color: Colors.purple, isDotted: true)] = points;
        }
      }
    });
  }

  _onMarkerTap(Marker marker) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdatePoster(
                  selectedPoster: markers[marker]!,
                  posterTagsLists: widget.posterTagsLists,
                  location: widget.currentPosition,
                  onUnhangPoster: (poster) => {
                    setState(() {
                      markers.remove(marker);
                    })
                  },
                  onUpdatePoster: (poster) => {
                    setState(() {
                      markers[marker] = poster;
                    })
                  },
                  selectedMarker: marker,
                )));
  }

  _getRefreshFab() {
    return FloatingActionButton(
      heroTag: "Center-FAB",
      onPressed: () {
        // Automatically center the location marker on the map when location updated until user interact with the map.
        setState(() => _centerOnLocationUpdate = CenterOnLocationUpdate.always);
        // Center the location marker on the map and zoom the map to level 18.
        _userPositionStreamController.add(18);
        widget.onRefresh();
      },
      child: Icon(
        Icons.my_location,
        color: Colors.white,
      ),
    );
  }

  _getAddPosterFab() {
    return FloatingActionButton(
      heroTag: "Add-Poster-FAB",
      child: Icon(Icons.add),
      tooltip: AppLocalizations.of(context)!.addPoster,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddPoster(
                    posterTagsLists: widget.posterTagsLists,
                    location: widget.currentPosition,
                    onAddPoster: (poster) =>
                        widget.posterInDistance.posterModels.add(poster),
                  )),
        );
      },
    );
  }

  _getMapOptions() {
    return MapOptions(
        center: widget.currentPosition,
        zoom: 13.0,
        plugins: [
          MarkerClusterPlugin(),
        ],
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if (hasGesture) {
            setState(
                () => _centerOnLocationUpdate = CenterOnLocationUpdate.never);
          }
        });
  }

  _getMarkerClusterLayerOptions() {
    return MarkerClusterLayerOptions(
      onMarkerTap: (marker) => _onMarkerTap(marker),
      size: Size(40, 40),
      fitBoundsOptions: FitBoundsOptions(
        padding: EdgeInsets.all(50),
      ),
      markers: markers.keys.toList(),
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

  _getPolyLineLayerOptions() {
    return PolylineLayerOptions(
      polylines: polylines.keys.toList(),
    );
  }
}
