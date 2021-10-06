
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart'
    show
    RadarEntry,
    RadarDataSet,
    RadarChart,
    RadarChartData,
    PieChart,
    PieChartData,
    PieChartSectionData;
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';
import 'package:random_color/random_color.dart';
import 'package:volt_campaigner/utils/screen_utils.dart';

class PieCharts extends StatefulWidget {
  PosterModels postersInDistance;
  PosterTagsLists posterTagsLists;

  PieCharts({Key? key,
    required this.postersInDistance,
    required this.posterTagsLists})
      : super(key: key);

  @override
  _PieCharts createState() => _PieCharts();
}

class _PieCharts extends State<PieCharts> {
  // ###############
  // PieChart
  // ###############
  // Motive
  List<PieChartSectionData> motivePieChartSectionData = [];
  Map<String, int> motiveCount = {};
  Map<String, Color> motiveColors = {};

  // Environment
  List<PieChartSectionData> environmentPieChartSectionData = [];
  Map<String, int> environmentCount = {};
  Map<String, Color> environmentColors = {};

  // Campaign
  List<PieChartSectionData> campaignPieChartSectionData = [];
  Map<String, int> campaignCount = {};
  Map<String, Color> campaignColors = {};

  // Type
  List<PieChartSectionData> typePieChartSectionData = [];
  Map<String, int> typeCount = {};
  Map<String, Color> typeColors = {};

  // Target Groups
  List<PieChartSectionData> targetGroupsPieChartSectionData = [];
  Map<String, int> targetGroupsCount = {};
  Map<String, Color> targetGroupsColors = {};

  // Other
  List<PieChartSectionData> otherPieChartSectionData = [];
  Map<String, int> otherCount = {};
  Map<String, Color> otherColors = {};


  TextStyle headingTextStyle =
  TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle noDataTextStyle =
  TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _getPieCharts();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pieCharts = [
      _getPieChart(AppLocalizations.of(context)!.posterMotive,
          motiveColors, motivePieChartSectionData),
      _getPieChart(AppLocalizations.of(context)!.posterEnvironment,
          environmentColors, environmentPieChartSectionData),
      _getPieChart(AppLocalizations.of(context)!.posterCampaign,
          campaignColors, campaignPieChartSectionData),
      _getPieChart(AppLocalizations.of(context)!.posterType,
          typeColors, typePieChartSectionData),
      _getPieChart(AppLocalizations.of(context)!.posterTargetGroups,
          targetGroupsColors, targetGroupsPieChartSectionData),
      _getPieChart(AppLocalizations.of(context)!.posterOther,
          otherColors, otherPieChartSectionData)
    ];
    return SingleChildScrollView(
      child: Column(
          children: [
            if(ScreenUtils.getScreenWidth(context) < 1300)
              Wrap(children: pieCharts)
            else
              Row(children: pieCharts)
          ],
        ),
    );
  }

  _getPieCharts() {
    // Motive{
    int posterCount = 0;
    for (PosterModel posterModel in widget.postersInDistance.posterModels) {
      posterCount += _calculatePieChartData(
          posterModel.posterTagsLists.posterMotive,
          widget.posterTagsLists.posterMotive,
          motiveCount,
          motiveColors);
    }
    _addPieChartData(motiveCount, motiveColors, posterCount,
        motivePieChartSectionData);

    // Environment
    posterCount = 0;
    for (PosterModel posterModel in widget.postersInDistance.posterModels) {
      posterCount += _calculatePieChartData(
          posterModel.posterTagsLists.posterEnvironment,
          widget.posterTagsLists.posterEnvironment,
          environmentCount,
          environmentColors);
    }
    _addPieChartData(environmentCount, environmentColors,
        posterCount, environmentPieChartSectionData);

    // Campaign
    posterCount = 0;
    for (PosterModel posterModel in widget.postersInDistance.posterModels) {
      posterCount += _calculatePieChartData(
          posterModel.posterTagsLists.posterCampaign,
          widget.posterTagsLists.posterCampaign,
          campaignCount,
          campaignColors);
    }
    _addPieChartData(campaignCount, campaignColors,
        posterCount, campaignPieChartSectionData);

    // Type
    posterCount = 0;
    for (PosterModel posterModel in widget.postersInDistance.posterModels) {
      posterCount += _calculatePieChartData(
          posterModel.posterTagsLists.posterType,
          widget.posterTagsLists.posterType,
          typeCount,
          typeColors);
    }
    _addPieChartData(typeCount, typeColors,
        posterCount, typePieChartSectionData);

    // Type
    posterCount = 0;
    for (PosterModel posterModel in widget.postersInDistance.posterModels) {
      posterCount += _calculatePieChartData(
          posterModel.posterTagsLists.posterTargetGroups,
          widget.posterTagsLists.posterTargetGroups,
          targetGroupsCount,
          targetGroupsColors);
    }
    _addPieChartData(targetGroupsCount, targetGroupsColors,
        posterCount, targetGroupsPieChartSectionData);

    // Other
    posterCount = 0;
    for (PosterModel posterModel in widget.postersInDistance.posterModels) {
      posterCount += _calculatePieChartData(
          posterModel.posterTagsLists.posterOther,
          widget.posterTagsLists.posterOther,
          otherCount,
          otherColors);
    }
    _addPieChartData(otherCount, otherColors,
        posterCount, otherPieChartSectionData);
  }

  _getPieChart(String title, Map<String, Color> colors,
      List<PieChartSectionData> pieChartSectionData) {
    return (Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: headingTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
        if (colors.length < 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.noData,
              style: noDataTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        Wrap(
            children: [
          for (String motive in colors.keys)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(Icons.circle, color: colors[motive]),
                Text(motive)
              ]),
            )
        ]),
        SizedBox(
            height: 200,
            width: 200,
            child: PieChart(
              PieChartData(
                sections: pieChartSectionData,
                centerSpaceRadius: 0,
              ),
              swapAnimationDuration: Duration(milliseconds: 150),
              // Optional
              swapAnimationCurve: Curves.linear, // Optional
            )),
      ],
    ));
  }

  int _calculatePieChartData(List<PosterTag> posterRealTags,
      List<PosterTag> posterTags,
      Map<String, int> posterTagCount,
      Map<String, Color> colors) {
    int _posterCount = 0;
    for (PosterTag posterTag in posterRealTags) {
      for (PosterTag posterTagCategory in posterTags) {
        if (posterTag.id == posterTagCategory.id) {
          _posterCount++;
          posterTagCount[posterTagCategory.name] =
              (posterTagCount[posterTagCategory.name] ?? 0) + 1;
        }
      }
    }
    return _posterCount;
  }

  _addPieChartData(Map<String, int> posterTagCount, Map<String, Color> colors,
      int posterCount, List<PieChartSectionData> pieChartSectionData) {
    RandomColor randomColor = RandomColor();
    posterTagCount.forEach((key, value) {
      Color color = randomColor.randomColor();
      colors[key] = color;
      double percentage =
      double.parse(((value / posterCount) * 100).toStringAsFixed(2));
      pieChartSectionData.add(PieChartSectionData(
          titlePositionPercentageOffset: 0.55,
          radius: 75,
          value: value.toDouble(),
          title: "$percentage%\n$value",
          color: color));
    });
  }
}
