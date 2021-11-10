import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'
    show FlutterMap, MapController, MapOptions;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:volt_campaigner/map/map_settings.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:volt_campaigner/map/poster_map.dart' as p;
import 'package:volt_campaigner/utils/api/model/area.dart';
import 'package:volt_campaigner/utils/http_utils.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'add_area.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddAreaMap extends StatefulWidget {
  LatLng currentPosition;
  String apiToken;
  String id;
  String name;
  int maxPosterCount;
  OnAddArea onAddArea;
  List<LatLng>? points;
  p.OnRefresh onRefresh;

  AddAreaMap(
      {Key? key,
      required this.id,
      required this.currentPosition,
      required this.apiToken,
      required this.name,
      required this.maxPosterCount,
      required this.onAddArea,
      this.points,
      required this.onRefresh})
      : super(key: key);

  @override
  _AddAreaMapState createState() => _AddAreaMapState();
}

class _AddAreaMapState extends State<AddAreaMap> {
  MapController mapController = new MapController();
  late PolyEditor polyEditor;
  List<Polygon> polygons = [];
  late Polygon addPolygon;
  double zoom = 17;

  @override
  void initState() {
    super.initState();
    addPolygon = new Polygon(
        borderStrokeWidth: 5,
        points: widget.points ?? [],
        color: Color.fromARGB(50, 255, 0, 0),
        borderColor: Colors.purple);
    polyEditor = new PolyEditor(
      addClosePathMarker: true,
      points: addPolygon.points,
      pointIcon: Icon(Icons.crop_square, size: 23),
      intermediateIcon: Icon(Icons.lens, size: 15, color: Colors.grey),
      callbackRefresh: () => {this.setState(() {})},
    );
    polygons.add(addPolygon);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
        mapController: mapController,
        children: [
          MapSettings.getTileLayerWidget(),
        ],
        options: MapOptions(
          center: widget.currentPosition,
          zoom: 17.0,
          plugins: [DragMarkerPlugin()],
          allowPanningOnScrollingParent: false,
          onTap: (_, ll) {
            polyEditor.add(addPolygon.points, ll);
          },
        ),
        layers: [
          PolygonLayerOptions(polygons: polygons),
          DragMarkerPluginOptions(markers: polyEditor.edit()),
        ],
      ),
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
      if (polyEditor.points.length > 2)
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            child: Icon(Icons.save),
            heroTag: "AddAreaMap",
            onPressed: () => _addArea(),
          ),
        )
    ]);
  }

  _addArea() async {
    List<Map<String, double>> points = [];
    for (LatLng p in addPolygon.points) {
      points.add({"latitude": p.latitude, "longitude": p.longitude});
    }
    points.add({
      "latitude": addPolygon.points.first.latitude,
      "longitude": addPolygon.points.first.longitude
    });
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/area/create"),
          headers: HttpUtils.createHeader(widget.apiToken),
          body: jsonEncode({
            'id': widget.id,
            'name': widget.name,
            'max_poster': widget.maxPosterCount,
            'points': points,
          }));
      if (response.statusCode == 201) {
        // widget.onAddArea(AreaModel.fromJson(jsonDecode(response.body)));
        Navigator.pop(context);
      } else {
        print(response.body);
        Messenger.showError(
            context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      Messenger.showError(
          context, AppLocalizations.of(context)!.errorAddPoster);
    }
    widget.onRefresh();
  }
}
