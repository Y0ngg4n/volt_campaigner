import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:file_saver/file_saver.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:csv/csv.dart';

class ExportView extends StatefulWidget {
  PosterModels posterModels;
  PosterTagsLists posterTagsLists;

  ExportView(
      {Key? key, required this.posterModels, required this.posterTagsLists})
      : super(key: key);

  @override
  _ExportViewState createState() => _ExportViewState();
}

class _ExportViewState extends State<ExportView> {
  TextStyle headingTextStyle = new TextStyle(fontSize: 20);

  @override
  void initState() {
    super.initState();
    // _fillMissingTagDetails(widget.selectedPoster.posterTagsLists.posterType);
    // _fillMissingTagDetails(widget.selectedPoster.posterTagsLists.posterMotive);
    // _fillMissingTagDetails(
    //     widget.selectedPoster.posterTagsLists.posterTargetGroups);
    // _fillMissingTagDetails(
    //     widget.selectedPoster.posterTagsLists.posterEnvironment);
    // _fillMissingTagDetails(widget.selectedPoster.posterTagsLists.posterOther);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!.poster,
                    style: headingTextStyle, textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () => _exportKML(),
                    child: Text(AppLocalizations.of(context)!.exportAs + "KML")),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () => _exportJSON(),
                    child: Text(AppLocalizations.of(context)!.exportAs + "JSON")),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () => _exportXML(),
                    child: Text(AppLocalizations.of(context)!.exportAs + "XML")),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () => _exportCSV(),
                    child: Text(AppLocalizations.of(context)!.exportAs + "CSV/EXCEL")),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _createPoints() {
    var gpx = Gpx();
    gpx.creator = "dart-gpx library";
    gpx.wpts = [];

    for (PosterModel posterModel in widget.posterModels.posterModels) {
      gpx.wpts.add(Wpt(
          lat: posterModel.location.latitude,
          lon: posterModel.location.longitude,
          ele: 10.0,
          name: posterModel.id,
          desc: posterModel.account));
    }
    return gpx;
  }

  _exportKML() async {
    var gpx = _createPoints();
    var kmlString = KmlWriter(altitudeMode: AltitudeMode.clampToGround)
        .asString(gpx, pretty: true);
    await FileSaver.instance.saveFile("CampaignerExport",
        new Uint8List.fromList(kmlString.codeUnits), ".kml");
    Messenger.showSuccess(context, AppLocalizations.of(context)!.successExport);
  }

  _exportXML() async {
    var gpx = _createPoints();
    var gpxString = GpxWriter().asString(gpx, pretty: true);
    await FileSaver.instance.saveFile("CampaignerExport",
        new Uint8List.fromList(gpxString.codeUnits), ".xml");
    Messenger.showSuccess(context, AppLocalizations.of(context)!.successExport);
  }
  
  _exportJSON() async {
    String string = jsonEncode(widget.posterModels.toJson());
    await FileSaver.instance.saveFile("CampaignerExport",
        new Uint8List.fromList(string.codeUnits), ".json");
    Messenger.showSuccess(context, AppLocalizations.of(context)!.successExport);
  }

  _exportCSV() async {
    List<List<dynamic>> csvList = [];
    csvList.add(["Type", "Latitude", "Longitude", "Account", "Hanging"]);
    for (PosterModel posterModel in widget.posterModels.posterModels) {
      List<String> data = [posterModel.id, posterModel.location.latitude.toString(), posterModel.location.longitude.toString(),
      posterModel.account, posterModel.hanging.toString()];
      csvList.add(data);
    }
    String string =  ListToCsvConverter().convert(csvList);
    await FileSaver.instance.saveFile("CampaignerExport",
        new Uint8List.fromList(string.codeUnits), ".csv");
    Messenger.showSuccess(context, AppLocalizations.of(context)!.successExport);
  }
}
