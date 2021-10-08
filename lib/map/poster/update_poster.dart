import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_settings.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/http_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef OnUnhangPoster = Function(PosterModel);
typedef OnUpdatePoster = Function(PosterModel);

class UpdatePoster extends StatefulWidget {
  PosterTagsLists posterTagsLists;
  LatLng location;
  OnUnhangPoster onUnhangPoster;
  OnUpdatePoster onUpdatePoster;
  Marker selectedMarker;
  PosterModel selectedPoster;
  PosterTags campaignTags;
  String apiToken;

  UpdatePoster(
      {Key? key,
      required this.posterTagsLists,
      required this.location,
      required this.onUnhangPoster,
      required this.onUpdatePoster,
      required this.selectedMarker,
      required this.selectedPoster,
      required this.campaignTags,
      required this.apiToken})
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

  late SharedPreferences prefs;
  int hanging = 0;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          hanging =
              (prefs.get(SharedPrefsSlugs.posterHanging) ?? hanging) as int;
        }));
    setState(() {
      selectedPosterTypes = widget.selectedPoster.posterTagsLists.posterType;
      selectedMotiveTypes = widget.selectedPoster.posterTagsLists.posterMotive;
      selectedTargetGroupTypes =
          widget.selectedPoster.posterTagsLists.posterTargetGroups;
      selectedEnvironmentTypes =
          widget.selectedPoster.posterTagsLists.posterEnvironment;
      selectedOtherTypes = widget.selectedPoster.posterTagsLists.posterOther;
    });
    print(selectedPosterTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.posterEdit)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 250),
            child: Column(children: [
              PosterSettings.getHeading(
                  AppLocalizations.of(context)!.posterType),
              PosterSettings.getTags(
                  context,
                  widget.posterTagsLists.posterType,
                  selectedPosterTypes,
                  (p, selectedPosterTags) =>
                      _onTagSelected(p, selectedPosterTags, false)),
              Divider(),
              PosterSettings.getHeading(
                  AppLocalizations.of(context)!.posterMotive),
              PosterSettings.getTags(
                  context,
                  widget.posterTagsLists.posterMotive,
                  selectedMotiveTypes,
                  (p, selectedPosterTags) =>
                      _onTagSelected(p, selectedPosterTags, true)),
              Divider(),
              PosterSettings.getHeading(
                  AppLocalizations.of(context)!.posterTargetGroups),
              PosterSettings.getTags(
                  context,
                  widget.posterTagsLists.posterTargetGroups,
                  selectedTargetGroupTypes,
                  (p, selectedPosterTags) =>
                      _onTagSelected(p, selectedPosterTags, true)),
              Divider(),
              PosterSettings.getHeading(
                  AppLocalizations.of(context)!.posterEnvironment),
              PosterSettings.getTags(
                  context,
                  widget.posterTagsLists.posterEnvironment,
                  selectedEnvironmentTypes,
                  (p, selectedPosterTags) =>
                      _onTagSelected(p, selectedPosterTags, true)),
              Divider(),
              PosterSettings.getHeading(
                  AppLocalizations.of(context)!.posterOther),
              PosterSettings.getTags(
                  context,
                  widget.posterTagsLists.posterOther,
                  selectedOtherTypes,
                  (p, selectedPosterTags) =>
                      _onTagSelected(p, selectedPosterTags, true)),
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
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: OutlinedButton(
                        onPressed: () =>
                            _updatePoster(widget.selectedPoster, 2),
                        child: Row(
                          children: [
                            Icon(Icons.repeat),
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
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
    );
  }

  _onTagSelected(
      PosterTag p, List<PosterTag> selectedPosterTags, bool multiple) {
    setState(() {
      PosterSettings.onTagSelected(p, selectedPosterTags, multiple);
    });
  }

  _updatePoster(PosterModel posterModel, int hanging) async {
    try {
      http.Response response = await http.post(
          Uri.parse((dotenv.env['REST_API_URL']!) + "/poster/update"),
          headers: HttpUtils.createHeader(widget.apiToken),
          body: jsonEncode({
            'id': posterModel.id,
            'campaign':
                widget.campaignTags.posterTags.map((e) => e.id).toList(),
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
