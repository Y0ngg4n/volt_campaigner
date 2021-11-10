import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_settings.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:volt_campaigner/utils/api/model/placemark.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/http_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';

typedef OnAddPlacemark = Function(PlacemarkModel);

class AddPlacemark extends StatefulWidget {
  LatLng location;
  OnAddPlacemark onAddPlacemark;
  LatLng centerLocation;
  String apiToken;
  PosterModel? preset;
  bool placeMarkerByHand;

  AddPlacemark(
      {Key? key,
      required this.location,
      required this.onAddPlacemark,
      required this.centerLocation,
      required this.apiToken,
      this.preset,
      required this.placeMarkerByHand})
      : super(key: key);

  @override
  _AddPlacemarkState createState() => _AddPlacemarkState();
}

enum PlaceMarkType { STORAGE, MEETPOINT }

class _AddPlacemarkState extends State<AddPlacemark> {
  PlaceMarkType placeMarkType = PlaceMarkType.STORAGE;
  String title = "";
  String description = "";

  @override
  Widget build(BuildContext context) {
    List<String> typeText = [
      AppLocalizations.of(context)!.placemarkTypeStorage,
      AppLocalizations.of(context)!.placemarkTypeMeetpoint,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.posterAdd)),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        this.title = value;
                      });
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text(AppLocalizations.of(context)!.title))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        this.description = value;
                      });
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text(AppLocalizations.of(context)!.description)),
                    keyboardType: TextInputType.multiline,
                    maxLines: null),
              ),
              DropdownButton(
                  value: typeText[placeMarkType.index],
                  onChanged: (value) {
                    setState(() {
                      this.placeMarkType = PlaceMarkType
                          .values[typeText.indexOf(value.toString())];
                    });
                  },
                  items: typeText.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity,
                          50), // double.infinity is the width and 30 is the height
                    ),
                    onPressed: () => _addPlacemark(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.save),
                        ),
                        Text(AppLocalizations.of(context)!.addPlacemark),
                      ],
                    )),
              )
            ],
          ),
        ),
      )),
    );
  }

  _addPlacemark() async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/placemark/create"),
          headers: HttpUtils.createHeader(widget.apiToken),
          body: jsonEncode({
            'latitude': widget.placeMarkerByHand
                ? widget.centerLocation.latitude
                : widget.location.latitude,
            'longitude': widget.placeMarkerByHand
                ? widget.centerLocation.longitude
                : widget.location.longitude,
            'title': title,
            'description': description,
            'type': placeMarkType.index
          }));
      print(response.body);
      if (response.statusCode == 201) {
        widget
            .onAddPlacemark(PlacemarkModel.fromJson(jsonDecode(response.body)));
        Navigator.pop(context);
      } else {
        Messenger.showError(
            context, AppLocalizations.of(context)!.errorAddPoster);
      }
    } catch (e) {
      print(e);
      Messenger.showError(
          context, AppLocalizations.of(context)!.errorAddPoster);
    }
  }
}
