import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:volt_campaigner/map/map_search.dart';
import 'package:volt_campaigner/map/map_settings.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:volt_campaigner/map/poster_map.dart' as poster_map;
import 'package:volt_campaigner/utils/api/model/flyer.dart';
import 'package:volt_campaigner/utils/api/nomatim.dart';
import 'package:volt_campaigner/utils/http_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/utils/messenger.dart';

class Flyer extends StatefulWidget {
  LatLng currentPosition;
  poster_map.OnLocationUpdate onLocationUpdate;
  poster_map.OnRefresh onRefresh;
  FlyerRoutes flyerRoutes;

  Flyer(
      {Key? key,
      required this.currentPosition,
      required this.onLocationUpdate,
      required this.onRefresh,
      required this.flyerRoutes})
      : super(key: key);

  @override
  FlyerState createState() => FlyerState();
}

class FlyerState extends State<Flyer> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _userPositionStreamController;
  late StreamSubscription<Position> _currentPositionStreamSubscription;
  List<LatLng> path = [];
  List<Marker> markers = [];
  Position? lastPosition;
  bool refreshing = false;
  bool running = false;
  var uuid = Uuid();
  late String ownUUID;
  late Timer timer;
  List<Polyline> polylines = [];
  List<Marker> userMarker = [];
  bool searching = false;
  MapController mapController = new MapController();
  final distance = 3;

  @override
  void dispose() {
    super.dispose();
    _currentPositionStreamSubscription.cancel();
    timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _userPositionStreamController = StreamController<double>();
    ownUUID = uuid.v4();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
        mapController: mapController,
        children: [
          MapSettings.getTileLayerWidget(),
          LocationMarkerLayerWidget(
            plugin: LocationMarkerPlugin(
              centerCurrentLocationStream: _userPositionStreamController.stream,
              centerOnLocationUpdate: _centerOnLocationUpdate,
            ),
          ),
        ],
        options: MapSettings.getMapOptions(
            (centerOnLocationUpdate) => setState(() {
                  _centerOnLocationUpdate = centerOnLocationUpdate;
                }),
            widget.currentPosition),
        layers: [
          PolylineLayerOptions(
            polylines: polylines,
          ),
          MarkerLayerOptions(
            markers: userMarker
          ),
        ],
        nonRotatedLayers: [],
      ),
      Positioned(
          right: 20,
          top: 20,
          child: MapSettings.getRefreshFab(context, (centerOnLocationUpdate) {
            setState(() {
              _centerOnLocationUpdate = centerOnLocationUpdate;
            });
          }, _userPositionStreamController, () => widget.onRefresh(),
              refreshing)),
      Positioned(left: 20, top: 20, child: _getSearchFab()),
      Positioned(right: 20, bottom: 20, child: _getStartStopButton())
    ]);
  }

  _startListener() async {
    setState(() {
      _currentPositionStreamSubscription =
          Geolocator.getPositionStream().listen((position) {
        _onPositionChanged(position);
      });
      timer = Timer.periodic(Duration(seconds: 30), (timer) {
        _upsert();
      });
    });
  }

  _getPolyLineFromPoints(List<LatLng> points) {
    return Polyline(
        points: points, strokeWidth: 5, color: Colors.green, isDotted: false);
  }

  _onPositionChanged(Position position) {
    if (lastPosition == null) {
      path.add(LatLng(position.latitude, position.longitude));
      lastPosition = position;
    } else {
      if (Geolocator.distanceBetween(lastPosition!.latitude,
              lastPosition!.longitude, position.latitude, position.longitude) >
          distance) {
        path.add(LatLng(position.latitude, position.longitude));
        lastPosition = position;
        refresh();
      }
    }
  }

  _stopListener() {
    _currentPositionStreamSubscription.cancel();
  }

  _getStartStopButton() {
    return FloatingActionButton(
      heroTag: "Start-Stop-FAB",
      child:
          Icon(running ? Icons.pause : Icons.play_arrow, color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        setState(() {
          running ? _stopListener() : _startListener();
          running = !running;
        });
      },
    );
  }

  _getSearchFab() {
    return FloatingActionButton(
      heroTag: "Search-FAB",
      child: Icon(Icons.search, color: Colors.white),
      tooltip: AppLocalizations.of(context)!.addPoster,
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () async {
        searching = true;
        _centerOnLocationUpdate = CenterOnLocationUpdate.never;
        try {
          NomatimSearchLocation nomatimSearchLocation =
          await showSearch(context: context, delegate: MapSearchDelegate());
          setState(() {
            widget.onLocationUpdate(LatLng(nomatimSearchLocation.latitude,
                nomatimSearchLocation.longitude));
            widget.onRefresh();
            mapController.move(
                LatLng(nomatimSearchLocation.latitude,
                    nomatimSearchLocation.longitude),
                13);
          });
        } catch (e) {}
      },
    );
  }

  _upsert() async {
    List<Map<String, double>> points = [];
    for (LatLng p in path) {
      points.add({"latitude": p.latitude, "longitude": p.longitude});
    }
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/flyer/route/upsert"),
          headers: HttpUtils.createHeader(),
          body: jsonEncode({"id": ownUUID, "polyline": points}));
      if (response.statusCode == 201) {
        print("Upserted Route");
      } else {
        print("Could not add route");
        print(response.body);
      }
    } catch (e) {
      print(e);
      // Messenger.showError(
      //     context, AppLocalizations.of(context)!.errorAddPoster);

    }
  }

  refresh() {
    setState(() {
      polylines.clear();
      for (FlyerRoute flyerRoute in widget.flyerRoutes.flyerRoutes) {
        if(flyerRoute.id == ownUUID) continue;
        polylines.add(flyerRoute.polyline);
        userMarker.add(new Marker(point: flyerRoute.polyline.points.last, anchorPos: AnchorPos.exactly(Anchor(25, 5)),
          // Offset by experimentation, (0,25) should work as well
          rotateOrigin: Offset(0, 20),
          width: 50,
          height: 50,
          rotate: true,
          builder: (ctx) => Icon(
            Icons.location_pin,
            size: 50,
            color: Colors.purple,
          ),
        ));
      }
      polylines.add(_getPolyLineFromPoints(path));
    });
  }

  setRefreshIcon(bool active) {
    setState(() {
      refreshing = active;
    });
  }
}
