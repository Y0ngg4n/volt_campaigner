import 'package:flutter/material.dart';
import 'package:volt_campaigner/settings/settings.dart';
import 'package:volt_campaigner/utils/api/model/poster.dart';

class ScreenUtils {

  static double getScreenWidth(BuildContext context) {
    return MediaQuery
        .of(context)
        .size
        .width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery
        .of(context)
        .size
        .height;
  }

  static Color getColorTagType(PosterModel posterModel, TagType colorTagType){
    Color markerColor = Colors.purple;
    if (colorTagType == TagType.TYPE &&
        posterModel.posterTagsLists.posterType.length > 0)
      markerColor = posterModel.posterTagsLists.posterType.first.color;
    else if (colorTagType == TagType.MOTIVE &&
        posterModel.posterTagsLists.posterMotive.length > 0)
      markerColor = posterModel.posterTagsLists.posterMotive.first.color;
    else if (colorTagType == TagType.TARGET_GROUP &&
        posterModel.posterTagsLists.posterTargetGroups.length > 0)
      markerColor =
          posterModel.posterTagsLists.posterTargetGroups.first.color;
    else if (colorTagType == TagType.ENVIRONMENT &&
        posterModel.posterTagsLists.posterEnvironment.length > 0)
      markerColor =
          posterModel.posterTagsLists.posterEnvironment.first.color;
    else if (colorTagType == TagType.OTHER &&
        posterModel.posterTagsLists.posterOther.length > 0)
      markerColor = posterModel.posterTagsLists.posterOther.first.color;
    else if (colorTagType == TagType.CAMPAIGN &&
        posterModel.posterTagsLists.posterCampaign.length > 0)
      markerColor = posterModel.posterTagsLists.posterCampaign.first.color;
    return markerColor;
  }

}