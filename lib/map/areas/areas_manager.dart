import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:volt_campaigner/map/areas/add_area.dart';
import 'package:volt_campaigner/utils/api/area.dart';
import 'package:volt_campaigner/utils/api/model/area.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnRefresh = Function(RefreshController);

class AreasManager extends StatefulWidget {
  LatLng currentPosition;
  String apiToken;
  Areas areaModels;
  OnRefresh onRefresh;

  AreasManager(
      {Key? key,
      required this.currentPosition,
      required this.apiToken,
      required this.areaModels,
      required this.onRefresh})
      : super(key: key);

  @override
  _AreasManagerState createState() => _AreasManagerState();
}

class _AreasManagerState extends State<AreasManager> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  TextEditingController textEditingController = new TextEditingController();
  String searchWord = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                this.searchWord = value;
              });
            },
          ),
          Expanded(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () => widget.onRefresh(_refreshController),
                controller: _refreshController,
                child: ListView.builder(
                    itemCount: widget.areaModels.areas.length,
                    itemBuilder: (BuildContext context, int index) {
                      AreaModel item = widget.areaModels.areas[index];
                      if (item.name.isEmpty ||
                          item.name
                              .toLowerCase()
                              .contains(searchWord.toLowerCase())) {
                        return ListTile(
                          title: Text(
                              item.name + ": " + item.maxPoster.toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => AddArea(
                                                id: item.id,
                                                onRefresh: () =>
                                                    widget.onRefresh(
                                                        _refreshController),
                                                currentPosition:
                                                    widget.currentPosition,
                                                apiToken: widget.apiToken,
                                                name: item.name,
                                                maxPosterCount: item.maxPoster,
                                                points: item.points.points,
                                                onAddArea: (areaModel) =>
                                                    widget.onRefresh(
                                                        _refreshController))));
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    _showDeleteConfirm(item);
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          ),
                        );
                      } else
                        return Container();
                    })),
          ),
        ],
      ),
      Positioned(
        bottom: 20,
        right: 20,
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddArea(
                    onRefresh: () => widget.onRefresh(_refreshController),
                    apiToken: widget.apiToken,
                    currentPosition: widget.currentPosition,
                    onAddArea: (area) {
                      widget.onRefresh(_refreshController);
                    })));
          },
        ),
      )
    ]);
  }

  _showDeleteConfirm(AreaModel areaModel) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.sureDelete),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteArea(areaModel);
                  _refreshController.requestRefresh();
                },
                child: Text(AppLocalizations.of(context)!.yes),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.no))
            ],
          );
        });
  }

  _deleteArea(AreaModel areaModel) async {
    await AreaApiUtils.deleteArea(areaModel.id, widget.apiToken);
    _refreshController.refreshCompleted();
  }
}
