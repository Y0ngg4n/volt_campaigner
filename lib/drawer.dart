import 'dart:async';

import 'package:volt_campaigner/map/poster_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:volt_campaigner/utils/api/poster.dart';

import 'map/poster/add_poster.dart';
import 'map/poster/poster_tags.dart';
import 'package:latlong2/latlong.dart';

enum DrawerSelection { POSTER, FLYER }

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
  PosterTagsLists posterTagsLists = new PosterTagsLists();

  @override
  void initState() {
    super.initState();
    refreshTimer =
        Timer.periodic(Duration(seconds: 30), (Timer t) => _refresh());
    _refresh();
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
        ]),
      ),
    );
  }

  Widget _getBody() {
    switch (drawerSelection) {
      case DrawerSelection.POSTER:
        return PosterMapView(posterInDistance: posterInDistance,
          currentPosition: currentPosition,
          onLocationUpdate: (location) {
            setState(() {
              this.currentPosition = location;
            });
          },
          posterTagsLists: posterTagsLists,
          onRefresh: () => _refresh(),
        );
      case DrawerSelection.FLYER:
        return Container();
    }
  }

  _refresh() async {
    print("Refreshing");
    PosterModels posterModels = await PosterApiUtils.getPointsInDistance(
        currentPosition, 1000000000, 0) ??
        PosterModels.empty();
    setState(() {
      posterInDistance = posterModels;
    });
  }
}
