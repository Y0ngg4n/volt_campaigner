import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt_campaigner/map/poster/poster_settings.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:date_time_picker/date_time_picker.dart'
    show DateTimePicker, DateTimePickerType;
import 'package:volt_campaigner/utils/tag_utils.dart';

typedef OnCampaignSelected = Function(PosterTags);

enum TagType { TYPE, MOTIVE, TARGET_GROUP, ENVIRONMENT, OTHER, CAMPAIGN }
enum TagTypeWithNone {
  NONE,
  TYPE,
  MOTIVE,
  TARGET_GROUP,
  ENVIRONMENT,
  OTHER,
  CAMPAIGN
}

class SettingsView extends StatefulWidget {
  PosterTagsLists posterTagsLists;
  OnCampaignSelected onCampaignSelected;
  PosterTags campaignTags;

  SettingsView(
      {Key? key,
      required this.posterTagsLists,
      required this.onCampaignSelected,
      required this.campaignTags})
      : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  double posterRadius = 1000;
  double flyerRadius = 1000;
  double areasRadius = 1000;
  bool posterLoadAll = false;
  bool flyerLoadAll = false;
  bool areasLoadAll = false;
  bool showAreasOnMap = true;
  int hanging = 0;
  bool posterCustomDateSwitch = false;
  bool flyerCustomDateSwitch = false;
  bool areasCustomDateSwitch = false;
  String posterCustomDate = DateTime.fromMicrosecondsSinceEpoch(0).toString();
  String flyerCustomDate = DateTime.fromMicrosecondsSinceEpoch(0).toString();
  String areasCustomDate = DateTime.fromMicrosecondsSinceEpoch(0).toString();
  bool drawNearestPosterLine = false;
  bool placeMarkerByHand = false;
  TagType colorTagType = TagType.TYPE;
  TagTypeWithNone filterTagType = TagTypeWithNone.NONE;
  int filterTagIndex = 0;
  late SharedPreferences prefs;
  late List<bool> hangingSelected = [true, false, false];

  List<PosterTag> selectedCampaign = [];

  final double primaryFontSize = 20;
  final double secondardFontSize = 15;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          posterRadius =
              (prefs.getDouble(SharedPrefsSlugs.posterRadius) ?? posterRadius);
          flyerRadius =
              (prefs.getDouble(SharedPrefsSlugs.flyerRadius) ?? flyerRadius);
          areasRadius =
              (prefs.getDouble(SharedPrefsSlugs.areasRadius) ?? areasRadius);
          posterLoadAll =
              (prefs.getBool(SharedPrefsSlugs.posterLoadAll) ?? posterLoadAll);
          flyerLoadAll =
              (prefs.getBool(SharedPrefsSlugs.posterLoadAll) ?? flyerLoadAll);
          areasLoadAll =
              (prefs.getBool(SharedPrefsSlugs.areasLoadAll) ?? areasLoadAll);
          posterCustomDateSwitch =
              (prefs.getBool(SharedPrefsSlugs.posterCustomDateSwitch) ??
                  posterCustomDateSwitch);
          flyerCustomDateSwitch =
              (prefs.getBool(SharedPrefsSlugs.flyerCustomDateSwitch) ??
                  flyerCustomDateSwitch);
          areasCustomDateSwitch =
              (prefs.getBool(SharedPrefsSlugs.areasCustomDateSwitch) ??
                  areasCustomDateSwitch);
          hanging = (prefs.getInt(SharedPrefsSlugs.posterHanging) ?? hanging);
          posterCustomDate =
              (prefs.getString(SharedPrefsSlugs.posterCustomDate) ??
                  posterCustomDate);
          flyerCustomDate =
              (prefs.getString(SharedPrefsSlugs.flyerCustomDate) ??
                  flyerCustomDate);
          areasCustomDate =
              (prefs.getString(SharedPrefsSlugs.areasCustomDate) ??
                  areasCustomDate);
          showAreasOnMap = (prefs.getBool(SharedPrefsSlugs.showAreasOnMap) ??
              showAreasOnMap);
          drawNearestPosterLine =
              (prefs.getBool(SharedPrefsSlugs.drawNearestPosterLine) ??
                  drawNearestPosterLine);
          placeMarkerByHand =
              (prefs.getBool(SharedPrefsSlugs.placeMarkerByHand) ??
                  placeMarkerByHand);
          colorTagType = TagType
              .values[(prefs.getInt(SharedPrefsSlugs.colorTagType) ?? 0)];
          filterTagType = TagTypeWithNone
              .values[(prefs.getInt(SharedPrefsSlugs.filterTagType) ?? 0)];
          filterTagIndex = (prefs.getInt(SharedPrefsSlugs.filterTagType) ?? 0);

          PosterTags campaigns = PosterTags.fromJsonAll(jsonDecode(
              (prefs.getString(SharedPrefsSlugs.campaignTags) ?? "[]")));
          widget.onCampaignSelected(campaigns);
          for (PosterTag tag in widget.posterTagsLists.posterCampaign) {
            for (PosterTag campaign in campaigns.posterTags) {
              setState(() {
                if (tag.id == campaign.id) {
                  selectedCampaign.clear();
                  selectedCampaign.add(tag);
                }
              });
            }
          }

          hangingSelected =
              List.generate(3, (i) => i == hanging ? true : false);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _getPosterSettings(),
          _getFlyerSettings(),
          _getAreaSettings()
        ],
      ),
    );
  }

  _getPosterSettings() {
    List<String> colorMarkerText = [
      AppLocalizations.of(context)!.posterType,
      AppLocalizations.of(context)!.posterMotive,
      AppLocalizations.of(context)!.posterTargetGroups,
      AppLocalizations.of(context)!.posterEnvironment,
      AppLocalizations.of(context)!.posterOther,
      AppLocalizations.of(context)!.posterCampaign
    ];

    List<String> colorMarkerTextWithNone = [
      "",
      AppLocalizations.of(context)!.posterType,
      AppLocalizations.of(context)!.posterMotive,
      AppLocalizations.of(context)!.posterTargetGroups,
      AppLocalizations.of(context)!.posterEnvironment,
      AppLocalizations.of(context)!.posterOther,
      AppLocalizations.of(context)!.posterCampaign
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppLocalizations.of(context)!.poster,
            style: TextStyle(
                fontSize: primaryFontSize, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.posterLoadAll),
            Switch(
              value: posterLoadAll,
              onChanged: (bool value) {
                setState(() {
                  posterLoadAll = value;
                  prefs.setBool(SharedPrefsSlugs.posterLoadAll, value);
                });
              },
            ),
          ],
        ),
        Visibility(
          visible: !posterLoadAll,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!.posterRadius +
                    _getRadiusPosterText()),
              ),
              Slider(
                  min: 100,
                  value: posterRadius,
                  max: 50000,
                  divisions: 100,
                  onChanged: (double value) {
                    setState(() {
                      posterRadius = value;
                      prefs.setDouble(SharedPrefsSlugs.posterRadius, value);
                    });
                  },
                  label: _getRadiusPosterText()),
            ],
          ),
        ),
        Visibility(
          visible: !posterLoadAll,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_getPosterHangingStatus()),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleButtons(
                  children: [
                    Icon(Icons.location_pin),
                    Icon(Icons.delete),
                    Icon(Icons.repeat)
                  ],
                  isSelected: hangingSelected,
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < hangingSelected.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          hangingSelected[buttonIndex] = true;
                          hanging = index;
                          prefs.setInt(SharedPrefsSlugs.posterHanging, hanging);
                        } else {
                          hangingSelected[buttonIndex] = false;
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Visibility(
            visible: !posterLoadAll,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!
                      .posterUpdateAfterDateSelection),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.posterCustomDate),
                    Switch(
                      value: posterCustomDateSwitch,
                      onChanged: (bool value) {
                        setState(() {
                          posterCustomDateSwitch = value;
                          prefs.setBool(
                              SharedPrefsSlugs.posterCustomDateSwitch, value);
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DateTimePicker(
                    enabled: posterCustomDateSwitch,
                    type: DateTimePickerType.dateTimeSeparate,
                    initialValue: posterCustomDate,
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: DateTime.now(),
                    dateLabelText: AppLocalizations.of(context)!.date,
                    timeLabelText: AppLocalizations.of(context)!.time,
                    onChanged: (val) => {
                      setState(() {
                        posterCustomDate = val;
                        prefs.setString(SharedPrefsSlugs.posterCustomDate, val);
                      })
                    },
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) => print(val),
                  ),
                )
              ],
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.drawNearestPosterLine),
            Switch(
              value: drawNearestPosterLine,
              onChanged: (value) {
                setState(() {
                  drawNearestPosterLine = value;
                  prefs.setBool(SharedPrefsSlugs.drawNearestPosterLine, value);
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.placeMarkerByHand),
            Switch(
              value: placeMarkerByHand,
              onChanged: (value) {
                setState(() {
                  placeMarkerByHand = value;
                  prefs.setBool(SharedPrefsSlugs.placeMarkerByHand, value);
                });
              },
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.colorMarker),
            DropdownButton(
                value: colorMarkerText[colorTagType.index],
                onChanged: (value) {
                  setState(() {
                    this.colorTagType = TagType
                        .values[colorMarkerText.indexOf(value.toString())];
                    prefs.setInt(
                        SharedPrefsSlugs.colorTagType, colorTagType.index);
                  });
                },
                items: colorMarkerText
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.filterMarker),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton(
                      value: colorMarkerTextWithNone[filterTagType.index],
                      onChanged: (value) {
                        setState(() {
                          this.filterTagType = TagTypeWithNone.values[
                              colorMarkerTextWithNone
                                  .indexOf(value.toString())];
                          prefs.setInt(SharedPrefsSlugs.filterTagType,
                              filterTagType.index);
                          this.filterTagIndex = 0;
                          prefs.setInt(
                              SharedPrefsSlugs.filterTagIndex, filterTagIndex);
                        });
                      },
                      items: colorMarkerTextWithNone
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton(
                      value: filterTagIndex,
                      onChanged: (value) {
                        setState(() {
                          filterTagIndex = value as int;
                          prefs.setInt(
                              SharedPrefsSlugs.filterTagIndex, filterTagIndex);
                        });
                      },
                      items: _getPosterTagsDropdownItems()),
                )
              ],
            ),
          ],
        ),
        Text(AppLocalizations.of(context)!.posterCampaign,
            style: TextStyle(fontSize: secondardFontSize)),
        PosterSettings.getTags(
            context,
            widget.posterTagsLists.posterCampaign,
            selectedCampaign,
            (p, selectedPosterTags) =>
                _onTagSelected(p, selectedPosterTags, false)),
        Divider(),
      ],
    );
  }

  _getPosterTagsDropdownItems() {
    List<DropdownMenuItem<int>> items = [];
    List<PosterTag> tags = TagUtils.getCorrespondingFilterPosterTags(
        filterTagType, widget.posterTagsLists);
    for (int i = 0; i < tags.length; i++) {
      print(i);
      items.add(DropdownMenuItem<int>(
        value: i,
        child: Text(tags[i].name),
      ));
    }
    return items;
  }

  _getFlyerSettings() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppLocalizations.of(context)!.flyer,
          style:
              TextStyle(fontSize: primaryFontSize, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.flyerLoadAll),
          Switch(
            value: flyerLoadAll,
            onChanged: (bool value) {
              setState(() {
                flyerLoadAll = value;
                prefs.setBool(SharedPrefsSlugs.flyerLoadAll, value);
              });
            },
          ),
        ],
      ),
      Visibility(
        visible: !flyerLoadAll,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)!.flyerRadius +
                  _getRadiusFlyerText()),
            ),
            Slider(
                min: 100,
                value: flyerRadius,
                max: 50000,
                divisions: 100,
                onChanged: (double value) {
                  setState(() {
                    flyerRadius = value;
                    prefs.setDouble(SharedPrefsSlugs.flyerRadius, value);
                  });
                },
                label: _getRadiusFlyerText()),
          ],
        ),
      ),
      Visibility(
          visible: !flyerLoadAll,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!
                    .flyerUpdateAfterDateSelection),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.flyerCustomDate),
                  Switch(
                    value: flyerCustomDateSwitch,
                    onChanged: (bool value) {
                      setState(() {
                        flyerCustomDateSwitch = value;
                        prefs.setBool(
                            SharedPrefsSlugs.flyerCustomDateSwitch, value);
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTimePicker(
                  enabled: flyerCustomDateSwitch,
                  type: DateTimePickerType.dateTimeSeparate,
                  initialValue: flyerCustomDate,
                  firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                  lastDate: DateTime.now(),
                  dateLabelText: AppLocalizations.of(context)!.date,
                  timeLabelText: AppLocalizations.of(context)!.time,
                  onChanged: (val) => {
                    setState(() {
                      flyerCustomDate = val;
                      prefs.setString(SharedPrefsSlugs.flyerCustomDate, val);
                    })
                  },
                  validator: (val) {
                    print(val);
                    return null;
                  },
                  onSaved: (val) => print(val),
                ),
              )
            ],
          )),
      Divider()
    ]);
  }

  _getAreaSettings() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppLocalizations.of(context)!.areas,
          style:
              TextStyle(fontSize: primaryFontSize, fontWeight: FontWeight.bold),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.areasLoadAll),
          Switch(
            value: areasLoadAll,
            onChanged: (bool value) {
              setState(() {
                areasLoadAll = value;
                prefs.setBool(SharedPrefsSlugs.areasLoadAll, value);
              });
            },
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.showAreasOnMap),
          Switch(
            value: showAreasOnMap,
            onChanged: (bool value) {
              setState(() {
                showAreasOnMap = value;
                prefs.setBool(SharedPrefsSlugs.showAreasOnMap, value);
              });
            },
          ),
        ],
      ),
      Visibility(
        visible: !areasLoadAll,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)!.areasRadius +
                  _getRadiusAreasText()),
            ),
            Slider(
                min: 100,
                value: areasRadius,
                max: 50000,
                divisions: 100,
                onChanged: (double value) {
                  setState(() {
                    areasRadius = value;
                    prefs.setDouble(SharedPrefsSlugs.areasRadius, value);
                  });
                },
                label: _getRadiusAreasText()),
          ],
        ),
      ),
      Visibility(
          visible: !areasLoadAll,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!
                    .areasUpdateAfterDateSelection),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.areasCustomDate),
                  Switch(
                    value: areasCustomDateSwitch,
                    onChanged: (bool value) {
                      setState(() {
                        areasCustomDateSwitch = value;
                        prefs.setBool(
                            SharedPrefsSlugs.areasCustomDateSwitch, value);
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTimePicker(
                  enabled: areasCustomDateSwitch,
                  type: DateTimePickerType.dateTimeSeparate,
                  initialValue: areasCustomDate,
                  firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                  lastDate: DateTime.now(),
                  dateLabelText: AppLocalizations.of(context)!.date,
                  timeLabelText: AppLocalizations.of(context)!.time,
                  onChanged: (val) => {
                    setState(() {
                      areasCustomDate = val;
                      prefs.setString(SharedPrefsSlugs.areasCustomDate, val);
                    })
                  },
                  validator: (val) {
                    print(val);
                    return null;
                  },
                  onSaved: (val) => print(val),
                ),
              )
            ],
          )),
    ]);
  }

  String _getRadiusPosterText() {
    return ((posterRadius / 1000).toStringAsFixed(1) + " km");
  }

  String _getRadiusFlyerText() {
    return ((flyerRadius / 1000).toStringAsFixed(1) + " km");
  }

  String _getRadiusAreasText() {
    return ((areasRadius / 1000).toStringAsFixed(1) + " km");
  }

  String _getPosterHangingStatus() {
    String text = AppLocalizations.of(context)!.posterHanginDescription;
    switch (hanging) {
      case 0:
        text += AppLocalizations.of(context)!.posterHangingStatus;
        break;
      case 1:
        text += AppLocalizations.of(context)!.posterUnhangStatus;
        break;
      case 2:
        text += AppLocalizations.of(context)!.posterRecycleStatus;
        break;
    }
    return text;
  }

  _onTagSelected(
      PosterTag p, List<PosterTag> selectedPosterTags, bool multiple) {
    setState(() {
      PosterSettings.onTagSelected(p, selectedPosterTags, multiple);
      widget.onCampaignSelected(PosterTags(selectedPosterTags));
      prefs.setString(
          SharedPrefsSlugs.campaignTags, jsonEncode(selectedPosterTags));
    });
  }
}
