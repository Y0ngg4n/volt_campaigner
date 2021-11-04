import 'package:volt_campaigner/map/poster/poster_tags.dart';

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
}