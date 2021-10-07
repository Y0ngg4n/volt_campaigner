import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/statistics/pie_charts.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';

class Statistics extends StatefulWidget {

  PosterModels postersInDistance;
  PosterTagsLists posterTagsLists;

  Statistics({Key? key,
    required this.postersInDistance,
    required this.posterTagsLists})
      : super(key: key);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [
      PieCharts(postersInDistance: widget.postersInDistance, posterTagsLists: widget.posterTagsLists)
    ],),);
  }
}
