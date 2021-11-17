import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_settings.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/api/poster.dart';
import 'package:volt_campaigner/utils/http_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';

typedef OnAddPoster = Function(PosterModel);

class AddPoster extends StatefulWidget {
  PosterTagsLists posterTagsLists;
  LatLng location;
  OnAddPoster onAddPoster;
  LatLng centerLocation;
  PosterTags campaignTags;
  String apiToken;
  PosterModel? preset;
  bool placeMarkerByHand;

  AddPoster(
      {Key? key,
      required this.posterTagsLists,
      required this.location,
      required this.onAddPoster,
      required this.centerLocation,
      required this.campaignTags,
      required this.apiToken,
      this.preset,
      required this.placeMarkerByHand})
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
    if (widget.preset != null) {
      selectedPosterTypes = widget.preset!.posterTagsLists.posterType;
      selectedMotiveTypes = widget.preset!.posterTagsLists.posterMotive;
      selectedTargetGroupTypes =
          widget.preset!.posterTagsLists.posterTargetGroups;
      selectedEnvironmentTypes =
          widget.preset!.posterTagsLists.posterEnvironment;
      selectedOtherTypes = widget.preset!.posterTagsLists.posterOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.posterAdd)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 150),
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
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: ElevatedButton(
                    onPressed: () => PosterApiUtils.addPoster(
                        widget.apiToken,
                        widget.placeMarkerByHand
                            ? widget.centerLocation
                            : widget.location,
                        PosterTagsLists(
                            widget.campaignTags.posterTags,
                            selectedPosterTypes,
                            selectedMotiveTypes,
                            selectedTargetGroupTypes,
                            selectedEnvironmentTypes,
                            selectedOtherTypes),
                        (poster) => widget.onAddPoster(poster),
                        context),
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
    );
  }

  _onTagSelected(
      PosterTag p, List<PosterTag> selectedPosterTags, bool multiple) {
    setState(() {
      PosterSettings.onTagSelected(p, selectedPosterTags, multiple);
    });
  }
}
