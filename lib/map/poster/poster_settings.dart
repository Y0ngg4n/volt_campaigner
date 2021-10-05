import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';

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

  static Widget getTags(List<PosterTag> posterTags,
      List<PosterTag> selectedPosterTags, OnTagSelected onTagSelected) {
    return Wrap(children: [
      for (PosterTag p in posterTags)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ChoiceChip(
            label: Text(p.name),
            selected: selectedPosterTags.contains(p),
            onSelected: (selected) {
              onTagSelected(p, selectedPosterTags);
            },
          ),
        ),
    ]);
  }
}