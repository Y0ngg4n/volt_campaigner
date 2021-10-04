import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:volt_campaigner/utils/http_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/utils/messenger.dart';

class AddPoster extends StatefulWidget {
  List<PosterTag> posterTypes;
  List<PosterTag> motiveTypes;
  List<PosterTag> targetGroupTypes;
  List<PosterTag> environmentTypes;
  List<PosterTag> otherTypes;
  LatLng location;

  AddPoster(
      {Key? key,
      required this.posterTypes,
      required this.motiveTypes,
      required this.targetGroupTypes,
      required this.environmentTypes,
      required this.otherTypes,
      required this.location})
      : super(key: key);

  @override
  _AddPosterState createState() => _AddPosterState();
}

class _AddPosterState extends State<AddPoster> {
  List<PosterTag> selectedPosterTypes = [];
  List<PosterTag> selectedMotiveTypes = [];
  List<PosterTag> selectedTargetGroupTypes = [];
  List<PosterTag> selectedEnvironmentTypes = [];
  List<PosterTag> selectedOtherTypes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.posterAdd)),
        body: Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(children: [
                  _getHeading(AppLocalizations.of(context)!.posterType),
                  _getTags(widget.posterTypes, selectedPosterTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterMotive),
                  _getTags(widget.motiveTypes, selectedMotiveTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterTargetGroups),
                  _getTags(widget.targetGroupTypes, selectedTargetGroupTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterEnvironment),
                  _getTags(widget.environmentTypes, selectedEnvironmentTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterOther),
                  _getTags(widget.otherTypes, selectedOtherTypes),
                ]),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: ElevatedButton(
                        onPressed: _addPoster,
                        child: Row(
                          children: [
                            Icon(Icons.save),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 16),
                              child: Text(
                                AppLocalizations.of(context)!.posterAdd,
                                style: TextStyle(fontSize: 25),
                              ),
                            )
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _getHeading(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(children: [
        Text(
          text,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )
      ]),
    );
  }

  Widget _getTags(
      List<PosterTag> posterTags, List<PosterTag> selectedPosterTags) {
    return Wrap(children: [
      for (PosterTag p in posterTags)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ChoiceChip(
            label: Text(p.name),
            selected: selectedPosterTags.contains(p),
            onSelected: (selected) {
              setState(() {
                if (selectedPosterTags.contains(p)) {
                  selectedPosterTags.remove(p);
                } else {
                  selectedPosterTags.add(p);
                }
              });
            },
          ),
        ),
    ]);
  }

  _addPoster() async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/create"),
          headers: HttpUtils.createHeader(),
          body: jsonEncode({
            'latitude': widget.location.latitude,
            'longitude': widget.location.longitude,
            'poster_type': selectedPosterTypes.map((e) => e.id).toList(),
            'motive': selectedMotiveTypes.map((e) => e.id).toList(),
            'target_groups': selectedTargetGroupTypes.map((e) => e.id).toList(),
            'environment': selectedEnvironmentTypes.map((e) => e.id).toList(),
            'other': selectedOtherTypes.map((e) => e.id).toList()
          }));
      if (response.statusCode == 201) {
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
