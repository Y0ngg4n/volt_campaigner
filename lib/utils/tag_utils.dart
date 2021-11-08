import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/settings/settings.dart';

class TagUtils {
  static fillMissingTagDetails(
      List<PosterTag> posterTagList, List<PosterTag> tagList) {
    for (PosterTag tag in tagList) {
      for (PosterTag posterTag in posterTagList) {
        if (tag.id == posterTag.id) {
          // if (posterTag.name.isEmpty) print("Filled missing");
          posterTagList[posterTagList.indexOf(posterTag)] = tag;
        }
      }
    }
  }

  static List<PosterTag> getCorrespondingFilterPosterTags(TagTypeWithNone filterTagType, PosterTagsLists posterTagsLists) {
    switch (filterTagType) {
      case TagTypeWithNone.NONE:
        return [];
      case TagTypeWithNone.TYPE:
        return posterTagsLists.posterType;
      case TagTypeWithNone.MOTIVE:
        return posterTagsLists.posterMotive;
      case TagTypeWithNone.TARGET_GROUP:
        return posterTagsLists.posterTargetGroups;
      case TagTypeWithNone.ENVIRONMENT:
        return posterTagsLists.posterEnvironment;
      case TagTypeWithNone.OTHER:
        return posterTagsLists.posterOther;
      case TagTypeWithNone.CAMPAIGN:
        return posterTagsLists.posterCampaign;
      default:
        return [];
    }
  }
}