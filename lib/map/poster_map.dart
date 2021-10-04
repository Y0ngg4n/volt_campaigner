import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/map/poster/add_poster.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:geolocator/geolocator.dart';

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
  List<Marker> markers = [];
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _userPositionStreamController;
  late StreamSubscription<Position> _currentPositionStreamSubscription;

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
  }

  Widget build(BuildContext context) {
    _addPosterMarker();

    return Stack(children: [
      FlutterMap(
        children: [
          TileLayerWidget(
            options: TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              maxZoom: 19,
            ),
          ),
          MarkerLayerWidget(
              options: MarkerLayerOptions(
            markers: markers,
          )),
          LocationMarkerLayerWidget(
            plugin: LocationMarkerPlugin(
              centerCurrentLocationStream: _userPositionStreamController.stream,
              centerOnLocationUpdate: _centerOnLocationUpdate,
            ),
          ),
        ],
        options: MapOptions(
            center: widget.currentPosition,
            zoom: 13.0,
            plugins: [
              MarkerClusterPlugin(),
            ],
            onPositionChanged: (MapPosition position, bool hasGesture) {
              if (hasGesture) {
                setState(() =>
                    _centerOnLocationUpdate = CenterOnLocationUpdate.never);
              }
            }),
        layers: [
          // MarkerClusterLayerOptions(
          //   maxClusterRadius: 120,
          //   size: Size(40, 40),
          //   fitBoundsOptions: FitBoundsOptions(
          //     padding: EdgeInsets.all(50),
          //   ),
          //   markers: markers,
          //   polygonOptions: PolygonOptions(
          //       borderColor: Colors.blueAccent,
          //       color: Colors.black12,
          //       borderStrokeWidth: 3),
          //   builder: (context, markers) {
          //     return FloatingActionButton(
          //       child: Text(markers.length.toString()),
          //       onPressed: null,
          //     );
          //   },
          //  ),
          MarkerLayerOptions(
            markers: markers,
          ),
        ],
      ),
      Positioned(
        right: 20,
        top: 20,
        child: FloatingActionButton(
          heroTag: "Center-FAB",
          onPressed: () {
            // Automatically center the location marker on the map when location updated until user interact with the map.
            setState(
                () => _centerOnLocationUpdate = CenterOnLocationUpdate.always);
            // Center the location marker on the map and zoom the map to level 18.
            _userPositionStreamController.add(18);
            widget.onRefresh();
          },
          child: Icon(
            Icons.my_location,
            color: Colors.white,
          ),
        ),
      ),
      Positioned(
        right: 20,
        bottom: 20,
        child: FloatingActionButton(
          heroTag: "Add-Poster-FAB",
          child: Icon(Icons.add),
          tooltip: AppLocalizations.of(context)!.addPoster,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddPoster(
                          posterTypes: widget.posterTagsLists.posterTypes,
                          motiveTypes: widget.posterTagsLists.posterTypes,
                          targetGroupTypes: widget.posterTagsLists.posterTypes,
                          environmentTypes: widget.posterTagsLists.posterTypes,
                          otherTypes: widget.posterTagsLists.posterTypes,
                          location: widget.currentPosition
                      )),
            );
          },
        ),
      )
    ]);
  }

  _addPosterMarker() {
    setState(() {
      markers.clear();
      for (PosterModel posterModel in widget.posterInDistance.posterModels) {
        markers.add(Marker(
          anchorPos: AnchorPos.exactly(Anchor(25, 5)),
          // Offset by experimentation, (0,25) should work as well
          rotateOrigin: Offset(0, 20),
          width: 50,
          height: 50,
          rotate: true,
          point: posterModel.location,
          builder: (ctx) => Icon(
            Icons.location_pin,
            size: 50,
          ),
        ));
      }
    });
  }
}
