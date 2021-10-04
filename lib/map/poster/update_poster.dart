import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/http_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:volt_campaigner/utils/messenger.dart';

typedef OnUnhangPoster = Function(PosterModel);
typedef OnUpdatePoster = Function(PosterModel);

class UpdatePoster extends StatefulWidget {
  PosterTagsLists posterTagsLists;
  LatLng location;
  OnUnhangPoster onUnhangPoster;
  OnUpdatePoster onUpdatePoster;
  Marker selectedMarker;
  PosterModel selectedPoster;

  UpdatePoster(
      {Key? key,
      required this.posterTagsLists,
      required this.location,
      required this.onUnhangPoster,
      required this.onUpdatePoster,
      required this.selectedMarker,
      required this.selectedPoster})
      : super(key: key);

  @override
  _UpdatePosterState createState() => _UpdatePosterState();
}

class _UpdatePosterState extends State<UpdatePoster> {
  List<PosterTag> selectedPosterTypes = [];
  List<PosterTag> selectedMotiveTypes = [];
  List<PosterTag> selectedTargetGroupTypes = [];
  List<PosterTag> selectedEnvironmentTypes = [];
  List<PosterTag> selectedOtherTypes = [];

  @override
  void initState() {
    super.initState();
    for (PosterTag tag in widget.posterTagsLists.posterTypes) {
      for (PosterTag posterTag in widget.selectedPoster.posterType) {
        if (tag.id == posterTag.id) {
          setState(() {
            widget.selectedPoster.posterType[
                widget.selectedPoster.posterType.indexOf(posterTag)] = tag;
          });
        }
      }
    }
    setState(() {
      selectedPosterTypes = widget.selectedPoster.posterType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.posterEdit)),
        body: Container(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(children: [
                  _getHeading(AppLocalizations.of(context)!.posterType),
                  _getTags(
                      widget.posterTagsLists.posterTypes, selectedPosterTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterMotive),
                  _getTags(
                      widget.posterTagsLists.posterTypes, selectedMotiveTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterTargetGroups),
                  _getTags(widget.posterTagsLists.posterTypes,
                      selectedTargetGroupTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterEnvironment),
                  _getTags(widget.posterTagsLists.posterTypes,
                      selectedEnvironmentTypes),
                  Divider(),
                  _getHeading(AppLocalizations.of(context)!.posterOther),
                  _getTags(
                      widget.posterTagsLists.posterTypes, selectedOtherTypes),
                ]),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Card(
                  child: Column(
                    children: [
                      Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: OutlinedButton(
                            onPressed: () =>
                                _updatePoster(widget.selectedPoster, 2),
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 16),
                                  child: Text(
                                    AppLocalizations.of(context)!.posterRecycle,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                )
                              ],
                            )),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: OutlinedButton(
                            onPressed: () =>
                                _updatePoster(widget.selectedPoster, 1),
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 16),
                                  child: Text(
                                    AppLocalizations.of(context)!.posterUnhang,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                )
                              ],
                            )),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: ElevatedButton(
                            onPressed: () =>
                                _updatePoster(widget.selectedPoster, 0),
                            child: Row(
                              children: [
                                Icon(Icons.save),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 16),
                                  child: Text(
                                    AppLocalizations.of(context)!.posterEdit,
                                    style: TextStyle(fontSize: 25),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ],
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

  _updatePoster(PosterModel posterModel, int hanging) async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/update"),
          headers: HttpUtils.createHeader(),
          body: jsonEncode({
            'id': posterModel.id,
            'hanging': hanging,
            'latitude': widget.location.latitude,
            'longitude': widget.location.longitude,
            'poster_type': selectedPosterTypes.map((e) => e.id).toList(),
            'motive': selectedMotiveTypes.map((e) => e.id).toList(),
            'target_groups': selectedTargetGroupTypes.map((e) => e.id).toList(),
            'environment': selectedEnvironmentTypes.map((e) => e.id).toList(),
            'other': selectedOtherTypes.map((e) => e.id).toList()
          }));
      if (response.statusCode == 201) {
        switch (hanging) {
          case 0:
            widget.onUpdatePoster(
                PosterModel.fromJson(jsonDecode(response.body)));
            break;
          case 1:
            widget.onUnhangPoster(
                PosterModel.fromJson(jsonDecode(response.body)));
            break;
          case 2:
            widget.onUnhangPoster(
                PosterModel.fromJson(jsonDecode(response.body)));
            break;
        }
        Navigator.pop(context);
      } else {
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
