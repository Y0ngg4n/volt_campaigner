import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/areas/add_area_map.dart';
import 'package:volt_campaigner/utils/api/model/area.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:volt_campaigner/map/poster_map.dart' as p;

typedef OnAddArea = Function(AreaModel);

class AddArea extends StatefulWidget {
  LatLng currentPosition;
  String apiToken;
  OnAddArea onAddArea;
  String? id;
  String? name;
  int? maxPosterCount;
  List<LatLng>? points;
  p.OnRefresh onRefresh;

  AddArea(
      {Key? key,
      required this.currentPosition,
      required this.apiToken,
      required this.onAddArea,
      this.name,
      this.maxPosterCount,
      this.points,
      this.id,
      required this.onRefresh})
      : super(key: key);

  @override
  _AddAreaState createState() => _AddAreaState();
}

class _AddAreaState extends State<AddArea> {
  String name = "Stadt";
  int maxPosterCount = 10;
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.name != null)
      setState(() {
        name = widget.name!;
      });
    if (widget.maxPosterCount != null)
      setState(() {
        maxPosterCount = widget.maxPosterCount!;
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.addArea)),
        body: Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: name,
                  onChanged: (value) {
                    setState(() {
                      this.name = value;
                    });
                  },
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.name),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: maxPosterCount.toString(),
                  onChanged: (value) {
                    setState(() {
                      this.maxPosterCount = int.parse(value);
                    });
                  },
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.maxPosterCount),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => AddAreaMap(
                              onRefresh: () => widget.onRefresh(),
                              id: widget.id ?? uuid.v4(),
                              apiToken: widget.apiToken,
                              name: name,
                              points: widget.points,
                              maxPosterCount: maxPosterCount,
                              currentPosition: widget.currentPosition,
                              onAddArea: (area) {})));
                    },
                    child: Text(AppLocalizations.of(context)!.addArea)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
