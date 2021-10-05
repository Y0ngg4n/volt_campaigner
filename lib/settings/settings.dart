import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:date_time_picker/date_time_picker.dart'
    show DateTimePicker, DateTimePickerType;

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  double radius = 100;
  bool loadAll = false;
  int hanging = 0;
  bool customDateSwitch = false;
  String customDate = DateTime.fromMicrosecondsSinceEpoch(0).toString();
  bool drawNearestPosterLine = false;
  bool placeMarkerByHand = false;
  late SharedPreferences prefs;
  late List<bool> hangingSelected = [true, false, false];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          radius =
              (prefs.get(SharedPrefsSlugs.posterRadius) ?? radius) as double;
          loadAll =
              (prefs.get(SharedPrefsSlugs.posterLoadAll) ?? loadAll) as bool;
          customDateSwitch =
              (prefs.get(SharedPrefsSlugs.posterCustomDateSwitch) ??
                  customDateSwitch) as bool;
          hanging =
              (prefs.get(SharedPrefsSlugs.posterHanging) ?? hanging) as int;
          customDate = (prefs.get(SharedPrefsSlugs.posterCustomDate) ??
              customDate) as String;
          drawNearestPosterLine =
              (prefs.get(SharedPrefsSlugs.drawNearestPosterLine) ?? customDate)
                  as bool;
          placeMarkerByHand =
          (prefs.get(SharedPrefsSlugs.placeMarkerByHand) ?? customDate)
          as bool;

          hangingSelected =
              List.generate(3, (i) => i == hanging ? true : false);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: !loadAll,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.posterLoadAll),
                  Switch(
                    value: loadAll,
                    onChanged: (bool value) {
                      setState(() {
                        loadAll = value;
                        prefs.setBool(SharedPrefsSlugs.posterLoadAll, value);
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!.posterRadius +
                    _getRadiusText()),
              ),
              Slider(
                  min: 100,
                  value: radius,
                  max: 10000,
                  divisions: 100,
                  onChanged: (double value) {
                    setState(() {
                      radius = value;
                      prefs.setDouble(SharedPrefsSlugs.posterRadius, value);
                    });
                  },
                  label: _getRadiusText()),
            ],
          ),
        ),
        Visibility(
          visible: !loadAll,
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
        Divider(),
        Visibility(
            visible: !loadAll,
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
                      value: customDateSwitch,
                      onChanged: (bool value) {
                        setState(() {
                          customDateSwitch = value;
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
                    enabled: customDateSwitch,
                    type: DateTimePickerType.dateTimeSeparate,
                    initialValue: customDate,
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: DateTime.now(),
                    dateLabelText: AppLocalizations.of(context)!.date,
                    timeLabelText: AppLocalizations.of(context)!.time,
                    onChanged: (val) => {
                      setState(() {
                        customDate = val;
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
        Divider(),
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
      ],
    );
  }

  String _getRadiusText() {
    return ((radius / 1000).toStringAsFixed(1) + " km");
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
}
