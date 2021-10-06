import 'dart:async';

import 'package:volt_campaigner/map/poster_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/settings/settings.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/api/poster.dart';
import 'package:volt_campaigner/utils/api/poster_tags.dart';

import 'map/poster/add_poster.dart';
import 'map/poster/poster_tags.dart';
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DrawerSelection { POSTER, FLYER, SETTINGS }

class DrawerView extends StatefulWidget {
  const DrawerView({Key? key}) : super(key: key);

  @override
  _DrawerViewState createState() => _DrawerViewState();
}

class _DrawerViewState extends State<DrawerView> {
  DrawerSelection drawerSelection = DrawerSelection.POSTER;

  PosterModels posterInDistance = new PosterModels([]);
  Timer? refreshTimer;

  LatLng currentPosition = LatLng(0, 0);
  PosterTagsLists posterTagsLists = PosterTagsLists.empty();
  late SharedPreferences prefs;
  final GlobalKey<PosterMapViewState> posterMapWidgetState =
      GlobalKey<PosterMapViewState>();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          Future.delayed(Duration(seconds: 1), ()=>_refresh());
        }));
    refreshTimer =
        Timer.periodic(Duration(seconds: 30), (Timer t) => _refresh());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: _getBody(),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.poster),
            onTap: () {
              setState(() {
                drawerSelection = DrawerSelection.POSTER;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.flyer),
            onTap: () {
              setState(() {
                drawerSelection = DrawerSelection.FLYER;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settings),
            onTap: () {
              setState(() {
                drawerSelection = DrawerSelection.SETTINGS;
              });
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  Widget _getBody() {
    switch (drawerSelection) {
      case DrawerSelection.POSTER:
        return _getPosterMapView();
      case DrawerSelection.FLYER:
        return Container();
      case DrawerSelection.SETTINGS:
        return SettingsView();
    }
  }

  _refresh() async {
    print("Refreshing");
    if (posterMapWidgetState.currentState != null)
      posterMapWidgetState.currentState!.setRefreshIcon(true);
    await _refreshPosterTags();
    await _refreshPoster();
    if (posterMapWidgetState.currentState != null){
      posterMapWidgetState.currentState!.refresh();
      posterMapWidgetState.currentState!.setRefreshIcon(false);
    }
  }

  _refreshPoster() async {
    int hanging = (prefs.get(SharedPrefsSlugs.posterHanging) ?? 0) as int;
    double radius =
        (prefs.get(SharedPrefsSlugs.posterRadius) ?? 100.0) as double;
    bool loadAll = (prefs.get(SharedPrefsSlugs.posterLoadAll) ?? false) as bool;
    bool customDateSwitch =
        (prefs.get(SharedPrefsSlugs.posterCustomDateSwitch) ?? false) as bool;
    String customDate = (prefs.get(SharedPrefsSlugs.posterCustomDate) ??
        DateTime.fromMicrosecondsSinceEpoch(0).toString()) as String;
    PosterModels posterModels;

    if (loadAll) {
      posterModels = await PosterApiUtils.getAllPosters(radius, hanging) ??
          PosterModels.empty();
    } else {
      if (customDateSwitch) {
        posterModels = await PosterApiUtils.getPostersInDistance(
                currentPosition, radius, hanging, customDate) ??
            PosterModels.empty();
      } else {
        posterModels = await PosterApiUtils.getPostersInDistance(
                currentPosition,
                radius,
                hanging,
                DateTime.fromMicrosecondsSinceEpoch(0).toString()) ??
            PosterModels.empty();
      }
    }

    setState(() {
      posterInDistance = posterModels;
    });
  }

  _getPosterMapView() {
    return PosterMapView(
      key: posterMapWidgetState,
      posterInDistance: posterInDistance,
      currentPosition: currentPosition,
      onLocationUpdate: (location) {
        setState(() {
          this.currentPosition = location;
        });
      },
      posterTagsLists: posterTagsLists,
      onRefresh: () => _refresh(),
    );
  }

  _refreshPosterTags() async {
    PosterTags campaign =
        await PosterTagApiUtils.getAllPosterTags('campaign') ?? PosterTags([]);
    PosterTags type =
        await PosterTagApiUtils.getAllPosterTags('type') ?? PosterTags([]);
    PosterTags motive =
        await PosterTagApiUtils.getAllPosterTags('motive') ?? PosterTags([]);
    PosterTags targetGroups =
        await PosterTagApiUtils.getAllPosterTags('target-groups') ??
            PosterTags([]);
    PosterTags environment =
        await PosterTagApiUtils.getAllPosterTags('environment') ??
            PosterTags([]);
    PosterTags other =
        await PosterTagApiUtils.getAllPosterTags('other') ?? PosterTags([]);
    setState(() {
      posterTagsLists = PosterTagsLists(
          campaign.posterTags,
          type.posterTags,
          motive.posterTags,
          targetGroups.posterTags,
          environment.posterTags,
          other.posterTags);
    });
  }
}
