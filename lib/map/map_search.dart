import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volt_campaigner/utils/api/nomatim.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapSearchDelegate extends SearchDelegate {
  StreamController<NomatimSearchLocations> streamController;

  MapSearchDelegate(this.streamController);

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
      icon: Icon(Icons.location_pin),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _addSearchResults(context);
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }

    return Column(
      children: <Widget>[
        //Build the results based on the searchResults stream in the searchBloc
        StreamBuilder(
          stream: streamController.stream,
          builder: (context, AsyncSnapshot<NomatimSearchLocations> snapshot) {
            if (!snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                ],
              );
            } else if (snapshot.data == null ||
                snapshot.data!.locations.length == 0) {
              return Column(
                children: <Widget>[
                  Text(
                    "No Results Found.",
                  ),
                ],
              );
            } else {
              var results = snapshot.data;
              return Expanded(
                  child: ListView.builder(
                itemCount: results!.locations.length,
                itemBuilder: (context, index) {
                  var result = results.locations[index];
                  return ListTile(
                    title: Text(result.displayName),
                    onTap: () {
                      close(context, result);
                    },
                  );
                },
              ));
            }
          },
        ),
      ],
    );
  }

  _addSearchResults(BuildContext context) async {
    print("Adding Results");
    streamController.sink.add(await NomatimApiUtils.search(query, context));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
}
