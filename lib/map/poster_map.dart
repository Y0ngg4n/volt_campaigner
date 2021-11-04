import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'
    show
        Anchor,
        AnchorPos,
        FitBoundsOptions,
        FlutterMap,
        MapController,
        MapOptions,
        MapPosition,
        Marker,
        Polygon,
        PolygonLayerOptions,
        Polyline,
        PolylineLayerOptions,
        TileLayerOptions,
        TileLayerWidget;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/drawer.dart';
import 'package:volt_campaigner/map/poster/add_poster.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/map/poster/update_poster.dart';
import 'package:volt_campaigner/map/map_search.dart';
import 'package:volt_campaigner/settings/settings.dart';
import 'package:volt_campaigner/utils/api/model/area.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:volt_campaigner/utils/api/nomatim.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_settings.dart';

typedef OnLocationUpdate = Function(LatLng);
typedef OnRefresh = Function();

class PosterMapView extends StatefulWidget {
  PosterModels posterInDistance;
  LatLng currentPosition;
  OnLocationUpdate onLocationUpdate;
  OnRefresh onRefresh;
  PosterTagsLists posterTagsLists;
  PosterTags campaignTags;
  String apiToken;
  String? photoUrl;
  OnDrawerOpen onDrawerOpen;
  Areas areasCovered;
  ContainsAreaLimits containsAreaLimits;

  PosterMapView(
      {Key? key,
      required this.posterInDistance,
      required this.currentPosition,
      required this.onLocationUpdate,
      required this.onRefresh,
      required this.posterTagsLists,
      required this.campaignTags,
      required this.apiToken,
      required this.photoUrl,
      required this.onDrawerOpen,
      required this.areasCovered,
      required this.containsAreaLimits})
      : super(key: key);

  @override
  PosterMapViewState createState() => PosterMapViewState();
}

class PosterMapViewState extends State<PosterMapView> {
  // Set default location to Volt Headquarter
  Map<Marker, PosterModel> markers = {};
  Map<Polyline, List<LatLng>> polylines = {};
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _userPositionStreamController;
  StreamSubscription<Position>? _currentPositionStreamSubscription;
  late SharedPreferences prefs;
  bool drawNearestPosterLine = false;
  bool showAreasOnMap = true;
  bool placeMarkerByHand = false;
  bool refreshing = false;
  MapController mapController = new MapController();
  bool searching = false;
  bool showHangingLimit = false;
  List<Areas> maxCountLimitedAreas = [];
  TagType colorTagType = TagType.TYPE;
  double zoom = 17;
  List<Polygon> polygons = [];

  @override
  void dispose() {
    super.dispose();
    if (_currentPositionStreamSubscription != null)
      _currentPositionStreamSubscription!.cancel();
  }

  _initPositionStream() {
    if (_currentPositionStreamSubscription != null) return;
    _currentPositionStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      print("New Position: " + position.toString());
      setState(() {
        if (!searching)
          widget
              .onLocationUpdate(LatLng(position.latitude, position.longitude));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _userPositionStreamController = StreamController<double>();
    _initPositionStream();
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          drawNearestPosterLine =
              (prefs.get(SharedPrefsSlugs.drawNearestPosterLine) ??
                  drawNearestPosterLine) as bool;
          placeMarkerByHand = (prefs.get(SharedPrefsSlugs.placeMarkerByHand) ??
              placeMarkerByHand) as bool;
          showAreasOnMap = (prefs.get(SharedPrefsSlugs.showAreasOnMap) ??
              showAreasOnMap) as bool;
          colorTagType = TagType
              .values[(prefs.getInt(SharedPrefsSlugs.colorTagType) ?? 0)];
        }));
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    _initPositionStream();
    return Stack(children: [
      FlutterMap(
        mapController: mapController,
        children: [
          MapSettings.getTileLayerWidget(),
          LocationMarkerLayerWidget(
            plugin: LocationMarkerPlugin(
              centerCurrentLocationStream:
                  _userPositionStreamController!.stream,
              centerOnLocationUpdate: _centerOnLocationUpdate,
            ),
          ),
        ],
        options: MapSettings.getMapOptions(
            zoom,
            (centerOnLocationUpdate) => setState(() {
                  _centerOnLocationUpdate = centerOnLocationUpdate;
                }),
            widget.currentPosition),
        layers: [
          _getPolyLineLayerOptions(),
          PolygonLayerOptions(
            polygons: polygons,
          ),
          MapSettings.getMarkerClusterLayerOptions(
              (marker) => _onMarkerTap(marker), markers.keys.toList()),
        ],
      ),
      Positioned(
          right: 20,
          top: 20,
          child: MapSettings.getRefreshFab(context, (centerOnLocationUpdate) {
            setState(() {
              searching = false;
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
              mapController.move(mapController.center, zoom);
            });
          })),
      Positioned(
          right: 20,
          top: 150,
          child: MapSettings.getZoomMinusButton(context, zoom, (zoom) {
            setState(() {
              this.zoom = zoom;
              mapController.move(mapController.center, zoom);
            });
          })),
      Positioned(right: 20, bottom: 20, child: _getAddPosterFab()),
      Positioned(left: 20, bottom: 20, child: _getLimitFab()),
      if (showHangingLimit)
        Positioned(
            left: 10,
            bottom: 85,
            child: Column(
              children: [_getLimitDataTable()],
            )),
      Positioned(
          left: 10,
          top: 10,
          child: MapSettings.getDrawerFab(
              context, widget.photoUrl, () => widget.onDrawerOpen())),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_getSearchFab()]),
      if (placeMarkerByHand)
        Positioned(
            top: 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Icon(Icons.location_pin, size: 50, color: Colors.deepPurple))
    ]);
  }

  _getLimitFab() {
    bool limitReached = false;
    for (ContainsAreaLimit containsAreaLimit
        in widget.containsAreaLimits.areas) {
      if (containsAreaLimit.hanging >= containsAreaLimit.maxPoster) {
        limitReached = true;
        break;
      }
    }
    return FloatingActionButton(
        heroTag: "Hanging-Limit-Toggle-FAB",
        backgroundColor:
            limitReached ? Colors.red : Theme.of(context).primaryColor,
        onPressed: () {
          setState(() {
            this.showHangingLimit = !this.showHangingLimit;
          });
        },
        child: showHangingLimit
            ? Icon(Icons.arrow_circle_down, color: Colors.white)
            : Icon(Icons.arrow_circle_up, color: Colors.white));
  }

  _getLimitDataTable() {
    return (Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: DataTable(horizontalMargin: 10, columnSpacing: 10, columns: [
        DataColumn(label: Text(AppLocalizations.of(context)!.name)),
        DataColumn(label: Text(AppLocalizations.of(context)!.max)),
        DataColumn(label: Text(AppLocalizations.of(context)!.hanging))
      ], rows: [
        for (ContainsAreaLimit limit in widget.containsAreaLimits.areas)
          DataRow(cells: [
            DataCell(Text(limit.name)),
            DataCell(Text(limit.maxPoster.toString(),
                style: limit.hanging >= limit.maxPoster
                    ? TextStyle(color: Colors.red)
                    : TextStyle())),
            DataCell(Text(limit.hanging.toString(),
                style: limit.hanging >= limit.maxPoster
                    ? TextStyle(color: Colors.red)
                    : TextStyle()))
          ])
      ]),
    )));
  }

  _addPosterMarker() {
    setState(() {
      markers.clear();
      for (PosterModel posterModel in widget.posterInDistance.posterModels) {
        Color markerColor = Colors.purple;
        if (colorTagType == TagType.TYPE &&
            posterModel.posterTagsLists.posterType.length > 0)
          markerColor = posterModel.posterTagsLists.posterType.first.color;
        else if (colorTagType == TagType.MOTIVE &&
            posterModel.posterTagsLists.posterMotive.length > 0)
          markerColor = posterModel.posterTagsLists.posterMotive.first.color;
        else if (colorTagType == TagType.TARGET_GROUP &&
            posterModel.posterTagsLists.posterTargetGroups.length > 0)
          markerColor =
              posterModel.posterTagsLists.posterTargetGroups.first.color;
        else if (colorTagType == TagType.ENVIRONMENT &&
            posterModel.posterTagsLists.posterEnvironment.length > 0)
          markerColor =
              posterModel.posterTagsLists.posterEnvironment.first.color;
        else if (colorTagType == TagType.OTHER &&
            posterModel.posterTagsLists.posterOther.length > 0)
          markerColor = posterModel.posterTagsLists.posterOther.first.color;
        else if (colorTagType == TagType.CAMPAIGN &&
            posterModel.posterTagsLists.posterCampaign.length > 0)
          markerColor = posterModel.posterTagsLists.posterCampaign.first.color;

        Marker marker = Marker(
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
            color: markerColor,
          ),
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
              points: points,
              strokeWidth: 4.0,
              color: Colors.purple,
              isDotted: true)] = points;
        }
      }
    });
  }

  _addPolygons() {
    if (showAreasOnMap) {
      setState(() {
        polygons.clear();
        for (AreaModel areaModel in widget.areasCovered.areas) {
          polygons.add(areaModel.points);
        }
      });
    }
  }

  _onMarkerTap(Marker marker) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdatePoster(
                  campaignTags: widget.campaignTags,
                  selectedPoster: markers[marker]!,
                  posterTagsLists: widget.posterTagsLists,
                  location: widget.currentPosition,
                  onUnhangPoster: (poster) {
                    setState(() {
                      markers.remove(marker);
                    });
                    refresh();
                  },
                  apiToken: widget.apiToken,
                  onUpdatePoster: (poster) {
                    setState(() {
                      markers[marker] = poster;
                    });
                    refresh();
                  },
                  selectedMarker: marker,
                )));
  }

  _getAddPosterFab() {
    return FloatingActionButton(
      heroTag: "Add-Poster-FAB",
      child: Icon(Icons.add, color: Colors.white),
      tooltip: AppLocalizations.of(context)!.addPoster,
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddPoster(
                    placeMarkerByHand: placeMarkerByHand,
                    apiToken: widget.apiToken,
                    campaignTags: widget.campaignTags,
                    posterTagsLists: widget.posterTagsLists,
                    location: widget.currentPosition,
                    centerLocation: mapController.center,
                    onAddPoster: (poster) {
                      widget.posterInDistance.posterModels.add(poster);
                      refresh();
                    },
                  )),
        );
      },
    );
  }

  _getSearchFab() {
    return Padding(
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
                context: context, delegate: MapSearchDelegate(widget.apiToken));
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
    );
  }

  refresh() {
    Future.microtask(() {
      _addPosterMarker();
      _addPolylines();
      _addPolygons();
    });
  }

  setRefreshIcon(bool active) {
    setState(() {
      refreshing = active;
    });
  }

  _getPolyLineLayerOptions() {
    return PolylineLayerOptions(
      polylines: polylines.keys.toList(),
    );
  }
}
