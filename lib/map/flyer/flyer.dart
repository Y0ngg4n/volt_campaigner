import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:volt_campaigner/auth/login.dart';
import 'package:volt_campaigner/drawer.dart';
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
import 'package:wakelock/wakelock.dart';
import 'package:feature_discovery/feature_discovery.dart';

class Flyer extends StatefulWidget {
  LatLng currentPosition;
  poster_map.OnLocationUpdate onLocationUpdate;
  poster_map.OnRefresh onRefresh;
  FlyerRoutes flyerRoutes;
  String apiToken;
  String? photoUrl;
  OnDrawerOpen onDrawerOpen;

  Flyer(
      {Key? key,
      required this.currentPosition,
      required this.onLocationUpdate,
      required this.onRefresh,
      required this.flyerRoutes,
      required this.apiToken,
      required this.photoUrl,
      required this.onDrawerOpen})
      : super(key: key);

  @override
  FlyerState createState() => FlyerState();
}

class FlyerState extends State<Flyer> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _userPositionStreamController;
  StreamSubscription<Position>? _currentPositionStreamSubscription;
  List<LatLng> path = [];
  List<Marker> markers = [];
  Position? lastPosition;
  bool refreshing = false;
  bool running = false;
  bool freeze = false;
  var uuid = Uuid();
  late String ownUUID;
  late Timer timer;
  List<Polyline> polylines = [];
  List<Marker> userMarker = [];
  bool searching = false;
  MapController mapController = new MapController();
  final distance = 3;
  double zoom = 17;

  @override
  void dispose() {
    super.dispose();
    if (_currentPositionStreamSubscription != null)
      _currentPositionStreamSubscription!.cancel();
    timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((Duration duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          // Feature ids for every feature that you want to showcase in order.
          'record-flyer',
        },
      );
    });
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _userPositionStreamController = StreamController<double>();
    ownUUID = uuid.v4();
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AbsorbPointer(
        absorbing: freeze,
        child: FlutterMap(
          mapController: mapController,
          children: [
            MapSettings.getTileLayerWidget(),
            LocationMarkerLayerWidget(
              plugin: LocationMarkerPlugin(
                centerCurrentLocationStream:
                    _userPositionStreamController.stream,
                centerOnLocationUpdate: _centerOnLocationUpdate,
              ),
            ),
          ],
          options: MapSettings.getMapOptions(
              zoom,
              (centerOnLocationUpdate) => setState(() {
                    _centerOnLocationUpdate = centerOnLocationUpdate;
                  }),
              widget.currentPosition,
              null),
          layers: [
            PolylineLayerOptions(
              polylines: polylines,
            ),
            MarkerLayerOptions(markers: userMarker),
          ],
          nonRotatedLayers: [],
        ),
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
      Positioned(
          right: 20,
          top: 85,
          child: MapSettings.getZoomPlusButton(context, zoom, (zoom) {
            setState(() {
              this.zoom = zoom;
              mapController.move(widget.currentPosition, zoom);
            });
          })),
      Positioned(
          right: 20,
          top: 150,
          child: MapSettings.getZoomMinusButton(context, zoom, (zoom) {
            setState(() {
              this.zoom = zoom;
              mapController.move(widget.currentPosition, zoom);
            });
          })),
      Positioned(
          left: 10,
          top: 10,
          child: MapSettings.getDrawerFab(
              context, widget.photoUrl, () => widget.onDrawerOpen())),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_getSearchFab()]),
      Positioned(right: 20, bottom: 20, child: _getStartStopButton()),
      if (running) Positioned(left: 20, bottom: 20, child: _getFreezeButton())
    ]);
  }

  _startListener() async {
    setState(() {
      _currentPositionStreamSubscription =
          Geolocator.getPositionStream().listen((position) {
        _onPositionChanged(position);
      });
      Wakelock.enable();
      Messenger.showWarning(
          context, AppLocalizations.of(context)!.letDisplayEnabled);
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

  _getFreezeButton() {
    return FloatingActionButton(
      heroTag: "Freeze-FAB",
      child: Icon(freeze ? Icons.lock_open : Icons.lock, color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        setState(() {
          freeze = !freeze;
        });
      },
    );
  }

  _stopListener() {
    if (_currentPositionStreamSubscription != null)
      _currentPositionStreamSubscription!.cancel();
    Wakelock.disable();
  }

  _getStartStopButton() {
    return DescribedFeatureOverlay(
        featureId: 'record-flyer',
        tapTarget: Icon(Icons.play_arrow),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        targetColor: Theme.of(context).primaryColor,
        title: Text(AppLocalizations.of(context)!.featureRecordFlyer),
        description:
            Text(AppLocalizations.of(context)!.featureRecordFlyerDescription),
        child: AbsorbPointer(
          absorbing: freeze,
          child: FloatingActionButton(
            heroTag: "Start-Stop-FAB",
            child: Icon(running ? Icons.pause : Icons.play_arrow,
                color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                running ? _stopListener() : _startListener();
                running = !running;
              });
            },
          ),
        ));
  }

  _getSearchFab() {
    return AbsorbPointer(
      absorbing: freeze,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FloatingActionButton(
          heroTag: "Search-FAB",
          child: Icon(Icons.search, color: Colors.white),
          tooltip: AppLocalizations.of(context)!.addPoster,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            searching = true;
            _centerOnLocationUpdate = CenterOnLocationUpdate.never;
            try {
              NomatimSearchLocation nomatimSearchLocation = await showSearch(
                  context: context,
                  delegate: MapSearchDelegate(widget.apiToken));
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
        ),
      ),
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
          headers: HttpUtils.createHeader(widget.apiToken),
          body: jsonEncode({"id": ownUUID, "polyline": points}));
      if (response.statusCode == 201) {
        print("Upserted Route");
      }else if (response.statusCode == 403) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()));
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
        if (flyerRoute.id == ownUUID) continue;
        polylines.add(flyerRoute.polyline);
        userMarker.add(new Marker(
          point: flyerRoute.polyline.points.last,
          anchorPos: AnchorPos.exactly(Anchor(25, 5)),
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
