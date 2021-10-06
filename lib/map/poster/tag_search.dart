import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/map/poster/poster_tags.dart';
import 'package:volt_campaigner/utils/api/nomatim.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TagSearchDelegate extends SearchDelegate {
  List<PosterTag> posterTags;

  TagSearchDelegate(this.posterTags);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<PosterTag> posterTagsSearch = posterTags.where((element) {
      return element.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Column(children: <Widget>[
      //Build the results based on the searchResults stream in the searchBloc
      if (posterTagsSearch.length == 0)
        Column(
          children: <Widget>[
            Text(
              "No Results Found.",
            ),
          ],
        )
      else
        Expanded(
            child: ListView.builder(
          itemCount: posterTagsSearch.length,
          itemBuilder: (context, index) {
            var result = posterTagsSearch[index];
            return ListTile(
              title: Text(result.name),
              onTap: () {
                close(context, result);
              },
            );
          },
        ))
    ]);
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
}
