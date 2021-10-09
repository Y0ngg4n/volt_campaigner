import 'dart:async';
import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:volt_campaigner/auth/login.dart';
import 'package:volt_campaigner/export/export.dart';
import 'package:volt_campaigner/flyer/flyer.dart';
import 'package:volt_campaigner/map/poster_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/settings/settings.dart';
import 'package:volt_campaigner/statistics/statistics.dart';
import 'package:volt_campaigner/statistics/pie_charts.dart';
import 'package:volt_campaigner/utils/api/flyer.dart';
import 'package:volt_campaigner/utils/api/model/flyer.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/api/poster.dart';
import 'package:volt_campaigner/utils/api/poster_tags.dart';
import 'package:volt_campaigner/volunteer/volunteer.dart';

import 'map/poster/add_poster.dart';
import 'map/poster/poster_tags.dart';
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef OnDrawerOpen = Function();

enum DrawerSelection {
  POSTER,
  FLYER,
  STATISTICS,
  VOLUNTEER,
  EXPORT,
  SETTINGS,
  LOGOUT
}

class DrawerView extends StatefulWidget {
  String apiToken;
  String? displayName, photoUrl, emailAddress;

  DrawerView(
      {Key? key,
      required this.apiToken,
      required this.displayName,
      required this.photoUrl,
      required this.emailAddress})
      : super(key: key);

  @override
  _DrawerViewState createState() => _DrawerViewState();
}

class _DrawerViewState extends State<DrawerView> {
  DrawerSelection drawerSelection = DrawerSelection.POSTER;

  PosterModels posterInDistance = new PosterModels([]);
  Timer? refreshTimer;

  LatLng currentPosition = LatLng(0, 0);
  PosterTagsLists posterTagsLists = PosterTagsLists.empty();
  PosterTags campaignTags = PosterTags([]);
  FlyerRoutes flyerRoutes = FlyerRoutes([]);
  late SharedPreferences prefs;
  final GlobalKey<PosterMapViewState> posterMapWidgetState =
      GlobalKey<PosterMapViewState>();
  final GlobalKey<FlyerState> flyerWidgetState = GlobalKey<FlyerState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) => setState(() {
          setState(() {
            prefs = value;
            campaignTags = PosterTags.fromJsonAll(jsonDecode(
                (prefs.getString(SharedPrefsSlugs.campaignTags) ?? "[]")));
            widget.apiToken =
                prefs.getString(SharedPrefsSlugs.restApiToken) ?? "";
          });

          Future.delayed(Duration(seconds: 1), () => _refresh());
          Future.delayed(Duration(seconds: 5), () => _refresh());
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
    if (drawerSelection == DrawerSelection.POSTER ||
        drawerSelection == DrawerSelection.FLYER) {
      return Scaffold(key: scaffoldKey, body: _getBody(), drawer: _getDrawer());
    } else {
      return Scaffold(
          key: scaffoldKey,
          appBar: new AppBar(title: Text(_getAppbarString())),
          body: _getBody(),
          drawer: _getDrawer());
    }
  }

  _getDrawer() {
    BoxDecoration drawerHeaderDecoration = widget.photoUrl != null
        ? BoxDecoration(
            color: Colors.blue,
            image: DecorationImage(
              image: NetworkImage(widget.photoUrl!),
              fit: BoxFit.fill,
            ))
        : BoxDecoration(
            color: Colors.blue,
          );

    return Drawer(
      child: ListView(children: [
        DrawerHeader(
          decoration: drawerHeaderDecoration,
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      widget.displayName == null
                          ? 'Volunteer'
                          : widget.displayName!,
                      style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      widget.emailAddress == null ? '' : widget.emailAddress!,
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
        _getListTile(
            AppLocalizations.of(context)!.poster, DrawerSelection.POSTER),
        _getListTile(
            AppLocalizations.of(context)!.flyer, DrawerSelection.FLYER),
        _getListTile(AppLocalizations.of(context)!.statistics,
            DrawerSelection.STATISTICS),
        _getListTile(
            AppLocalizations.of(context)!.volunteer, DrawerSelection.VOLUNTEER),
        _getListTile(
            AppLocalizations.of(context)!.settings, DrawerSelection.SETTINGS),
        _getListTile(
            AppLocalizations.of(context)!.export, DrawerSelection.EXPORT),
        _getListTile(
            AppLocalizations.of(context)!.logout, DrawerSelection.LOGOUT)
      ]),
    );
  }

  Widget _getListTile(String name, DrawerSelection drawerSelection) {
    return (ListTile(
      title: Text(name),
      onTap: () {
        setState(() {
          this.drawerSelection = drawerSelection;
        });
        Navigator.pop(context);
      },
    ));
  }

  Widget _getBody() {
    if (drawerSelection == DrawerSelection.LOGOUT) {
      prefs.remove(SharedPrefsSlugs.restApiToken);
      prefs.remove(SharedPrefsSlugs.googleAccessTokenData);
      prefs.remove(SharedPrefsSlugs.googleAccessTokenType);
      prefs.remove(SharedPrefsSlugs.googleAccessTokenData);
      prefs.remove(SharedPrefsSlugs.googleIdToken);
      prefs.remove(SharedPrefsSlugs.googleRefreshToken);
      prefs.remove(SharedPrefsSlugs.googleScopes);
      prefs.remove(SharedPrefsSlugs.googlePhotoUrl);
      prefs.remove(SharedPrefsSlugs.googleEmailAddress);
      prefs.remove(SharedPrefsSlugs.googleExpiry);
      prefs.remove(SharedPrefsSlugs.googleDisplayName);
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginView()),
              (route) => false);
        });
      });
    }
    switch (drawerSelection) {
      case DrawerSelection.POSTER:
        return _getPosterMapView();
      case DrawerSelection.FLYER:
        return _getFlyer();
      case DrawerSelection.STATISTICS:
        return Statistics(
          postersInDistance: posterInDistance,
          posterTagsLists: posterTagsLists,
        );
      case DrawerSelection.SETTINGS:
        return SettingsView(
            campaignTags: campaignTags,
            posterTagsLists: posterTagsLists,
            onCampaignSelected: (posterTags) => setState(() {
                  this.campaignTags = posterTags;
                }));
      case DrawerSelection.EXPORT:
        return ExportView(
          posterModels: posterInDistance,
          posterTagsLists: posterTagsLists,
        );
      case DrawerSelection.VOLUNTEER:
        return VolunteerView(apiToken: widget.apiToken);
      case DrawerSelection.LOGOUT:
        return Container();
    }
  }

  String _getAppbarString() {
    switch (drawerSelection) {
      case DrawerSelection.POSTER:
        return AppLocalizations.of(context)!.poster;
      case DrawerSelection.FLYER:
        return AppLocalizations.of(context)!.flyer;
      case DrawerSelection.STATISTICS:
        return AppLocalizations.of(context)!.statistics;
      case DrawerSelection.SETTINGS:
        return AppLocalizations.of(context)!.settings;
      case DrawerSelection.EXPORT:
        return AppLocalizations.of(context)!.export;
      case DrawerSelection.VOLUNTEER:
        return AppLocalizations.of(context)!.volunteer;
      case DrawerSelection.LOGOUT:
        return AppLocalizations.of(context)!.logout;
    }
  }

  _refresh() async {
    print("Refreshing");

    if (drawerSelection == DrawerSelection.POSTER) {
      if (posterMapWidgetState.currentState != null)
        posterMapWidgetState.currentState!.setRefreshIcon(true);
      await _refreshPosterTags();
      await _refreshPoster();
      if (posterMapWidgetState.currentState != null) {
        posterMapWidgetState.currentState!.refresh();
        posterMapWidgetState.currentState!.setRefreshIcon(false);
      }
      setState(() {
        for (PosterModel posterModel in posterInDistance.posterModels) {
          _fillMissingTagDetails(posterModel.posterTagsLists.posterType,
              posterTagsLists.posterType);
          _fillMissingTagDetails(posterModel.posterTagsLists.posterCampaign,
              posterTagsLists.posterCampaign);
          _fillMissingTagDetails(posterModel.posterTagsLists.posterEnvironment,
              posterTagsLists.posterEnvironment);
          _fillMissingTagDetails(posterModel.posterTagsLists.posterTargetGroups,
              posterTagsLists.posterTargetGroups);
          _fillMissingTagDetails(posterModel.posterTagsLists.posterOther,
              posterTagsLists.posterOther);
          _fillMissingTagDetails(posterModel.posterTagsLists.posterMotive,
              posterTagsLists.posterMotive);
        }
      });
    } else if (drawerSelection == DrawerSelection.FLYER) {
      if (flyerWidgetState.currentState != null) {
        flyerWidgetState.currentState!.setRefreshIcon(true);
      }
      FlyerRoutes? flyerRoutes = await FlyerApiUtils.getFlyerRoutesInDistance(
          currentPosition,
          1000000000000,
          DateTime.fromMicrosecondsSinceEpoch(0).toString(),
          widget.apiToken);
      if (flyerRoutes != null) {
        setState(() {
          this.flyerRoutes = flyerRoutes;
        });
      }
      if (flyerWidgetState.currentState != null) {
        flyerWidgetState.currentState!.refresh();
        flyerWidgetState.currentState!.setRefreshIcon(false);
      }
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
      posterModels = await PosterApiUtils.getAllPosters(
              radius, hanging, widget.apiToken) ??
          PosterModels.empty();
    } else {
      if (customDateSwitch) {
        posterModels = await PosterApiUtils.getPostersInDistance(
                currentPosition,
                radius,
                hanging,
                customDate,
                widget.apiToken) ??
            PosterModels.empty();
      } else {
        posterModels = await PosterApiUtils.getPostersInDistance(
                currentPosition,
                radius,
                hanging,
                DateTime.fromMicrosecondsSinceEpoch(0).toString(),
                widget.apiToken) ??
            PosterModels.empty();
      }
    }

    setState(() {
      posterInDistance = posterModels;
    });
  }

  _getPosterMapView() {
    return PosterMapView(
      photoUrl: widget.photoUrl,
      apiToken: widget.apiToken,
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
      campaignTags: campaignTags,
      onDrawerOpen: () {
        if (scaffoldKey.currentState != null)
          scaffoldKey.currentState!.openDrawer();
      },
    );
  }

  _getFlyer() {
    return Flyer(
      apiToken: widget.apiToken,
      key: flyerWidgetState,
      flyerRoutes: flyerRoutes,
      currentPosition: currentPosition,
      onLocationUpdate: (location) {
        setState(() {
          this.currentPosition = location;
        });
      },
      onRefresh: () => _refresh(),
      photoUrl: widget.photoUrl,
      onDrawerOpen: () {
        if (scaffoldKey.currentState != null)
          scaffoldKey.currentState!.openDrawer();
      },
    );
  }

  _refreshPosterTags() async {
    PosterTags campaign =
        await PosterTagApiUtils.getAllPosterTags('campaign', widget.apiToken) ??
            PosterTags([]);
    PosterTags type =
        await PosterTagApiUtils.getAllPosterTags('type', widget.apiToken) ??
            PosterTags([]);
    PosterTags motive =
        await PosterTagApiUtils.getAllPosterTags('motive', widget.apiToken) ??
            PosterTags([]);
    PosterTags targetGroups = await PosterTagApiUtils.getAllPosterTags(
            'target-groups', widget.apiToken) ??
        PosterTags([]);
    PosterTags environment = await PosterTagApiUtils.getAllPosterTags(
            'environment', widget.apiToken) ??
        PosterTags([]);
    PosterTags other =
        await PosterTagApiUtils.getAllPosterTags('other', widget.apiToken) ??
            PosterTags([]);
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

  _fillMissingTagDetails(
      List<PosterTag> posterTagList, List<PosterTag> tagList) {
    for (PosterTag tag in tagList) {
      for (PosterTag posterTag in posterTagList) {
        if (tag.id == posterTag.id) {
          if (posterTag.name.isEmpty) print("Filled missing");
          posterTagList[posterTagList.indexOf(posterTag)] = tag;
        }
      }
    }
  }
}
