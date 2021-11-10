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
import 'package:flutter_map/flutter_map.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_placemark.dart';

typedef OnUpdatePlacemark = Function(PlacemarkModel);

class UpdatePlacemarker extends StatefulWidget {
  LatLng location;
  Marker selectedMarker;
  PlacemarkModel selectedPlacemark;
  String apiToken;
  OnUpdatePlacemark onUpdatePlacemark;

  UpdatePlacemarker(
      {Key? key,
      required this.location,
      required this.selectedMarker,
      required this.selectedPlacemark,
      required this.onUpdatePlacemark,
      required this.apiToken})
      : super(key: key);

  @override
  _UpdatePlacemarkerState createState() => _UpdatePlacemarkerState();
}

class _UpdatePlacemarkerState extends State<UpdatePlacemarker> {
  late SharedPreferences prefs;
  PlaceMarkType placeMarkType = PlaceMarkType.STORAGE;
  String title = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    List<String> typeText = [
      AppLocalizations.of(context)!.placemarkTypeStorage,
      AppLocalizations.of(context)!.placemarkTypeMeetpoint,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.posterEdit)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 250),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                      initialValue: widget.selectedPlacemark.title,
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
                      initialValue: widget.selectedPlacemark.description,
                      onChanged: (value) {
                        setState(() {
                          this.description = value;
                        });
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label:
                              Text(AppLocalizations.of(context)!.description)),
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
                    items:
                        typeText.map<DropdownMenuItem<String>>((String value) {
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
                      onPressed: () => _updatePlacemark(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.save),
                          ),
                          Text(AppLocalizations.of(context)!.updatePlacemark),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity,
                            50), // double.infinity is the width and 30 is the height
                      ),
                      onPressed: () => _deletePlacemark(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.delete),
                          ),
                          Text(AppLocalizations.of(context)!.deletePlacemark),
                        ],
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _updatePlacemark() async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/placemark/update"),
          headers: HttpUtils.createHeader(widget.apiToken),
          body: jsonEncode({
            'id': widget.selectedPlacemark.id,
            'latitude': widget.location.latitude,
            'longitude': widget.location.longitude,
            'title': title,
            'description': description,
            'type': placeMarkType.index
          }));
      if (response.statusCode == 201) {
        widget.onUpdatePlacemark(PlacemarkModel.fromJson(jsonDecode(response.body)));
        Navigator.pop(context);
      } else {
        print(response.body);
        Messenger.showError(
            context, AppLocalizations.of(context)!.errorEditPoster);
      }
    } catch (e) {
      print(e);
      Messenger.showError(
          context, AppLocalizations.of(context)!.errorEditPoster);
    }
  }

  _deletePlacemark() async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/placemark/delete"),
          headers: HttpUtils.createHeader(widget.apiToken),
          body: jsonEncode({
            'id': widget.selectedPlacemark.id,
          }));
      if (response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        print(response.body);
        Messenger.showError(
            context, AppLocalizations.of(context)!.errorEditPoster);
      }
    } catch (e) {
      print(e);
      Messenger.showError(
          context, AppLocalizations.of(context)!.errorEditPoster);
    }
  }
}
