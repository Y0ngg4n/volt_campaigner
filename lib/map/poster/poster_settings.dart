import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/map/poster/tag_search.dart';

typedef OnTagSelected = Function(PosterTag, List<PosterTag>);

class PosterSettings {
  static Widget getHeading(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(children: [
        Text(
          text,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )
      ]),
    );
  }

  static Widget getTags(BuildContext context, List<PosterTag> posterTags,
      List<PosterTag> selectedPosterTags, OnTagSelected onTagSelected) {
    // Fix wrong instance. Better Options are welcome
    for (PosterTag p in posterTags)
      for (PosterTag posterTag in selectedPosterTags)
        if (posterTag.id == p.id)
          selectedPosterTags[selectedPosterTags.indexOf(posterTag)] = p;

    return Wrap(children: [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () async {
          PosterTag? posterTag = await showSearch(
              context: context,
              delegate: TagSearchDelegate(posterTags)) as PosterTag?;
          if (posterTag != null) onTagSelected(posterTag, selectedPosterTags);
        },
      ),
      for (PosterTag p in posterTags)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ChoiceChip(
            shape: StadiumBorder(side: BorderSide(color: p.color)),
            label: Text(p.name),
            selected: selectedPosterTags.contains(p),
            onSelected: (selected) {
              onTagSelected(p, selectedPosterTags);
            },
          ),
        ),
    ]);
  }

  static onTagSelected(
      PosterTag p, List<PosterTag> selectedPosterTags, bool multiple) {
    if (multiple) {
      if (selectedPosterTags.contains(p)) {
        selectedPosterTags.remove(p);
      } else {
        selectedPosterTags.add(p);
      }
    } else {
      selectedPosterTags.clear();
      selectedPosterTags.add(p);
    }
    return;
  }
}
