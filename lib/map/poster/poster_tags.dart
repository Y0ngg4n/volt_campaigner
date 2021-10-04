import 'dart:convert';

class PosterTag {
  String id;
  String name;

  PosterTag({required this.id, required this.name});

  PosterTag.fromJson(String id)
      : id = id, name = "";

}

class PosterTags {
  List<PosterTag> posterTags = [];

  PosterTags.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      posterTags.add(PosterTag.fromJson(entry));
    }
  }
}

class PosterTagsLists {
  List<PosterTag> posterTypes = [
    new PosterTag(id: "b45ebffb-a559-49dc-87e0-b3b760069d50", name: "Test"),
    new PosterTag(id: "b812c563-4eab-4d77-badd-e1375a597178", name: "Test2"),
    new PosterTag(
        id: "aea33423-b50f-4505-9179-c3ecc0fa836c",
        name: "sadasdasdasdasdassadsaa"),
    new PosterTag(id: "7f0e2e16-9ba5-4ed0-b001-2a346d2e68a5", name: "Test2"),
    new PosterTag(
        id: "a758c8d0-55a5-4432-94f9-e31db4cc76a0",
        name: "asdasdasdasdasdasdasdsa"),
    new PosterTag(id: "6", name: "Test2"),
    new PosterTag(id: "7", name: "adasdsadasdsadsadsadsad"),
    new PosterTag(id: "8", name: "Test2"),
    new PosterTag(id: "9", name: "asdasdasdasdasdasasassad"),
    new PosterTag(id: "10", name: "Test2")
  ];
}