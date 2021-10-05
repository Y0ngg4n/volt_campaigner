import 'dart:convert';

class PosterTag {
  String id;
  String name;
  bool active;

  PosterTag({required this.id, required this.name, required this.active});

  PosterTag.fromJson(String id)
      : id = id,
        name = "",
        active = true;

  PosterTag.fromJsonAll(Map<String, dynamic> json)
      : id = json['id'],
        name = json['description'],
        active = json['active'];
}

class PosterTags {
  List<PosterTag> posterTags = [];

  PosterTags.fromJson(List<dynamic> json) {
    for (dynamic entry in json) {
      posterTags.add(PosterTag.fromJson(entry));
    }
  }

  PosterTags.fromJsonAll(List<dynamic> json) {
    for (dynamic entry in json) {
      posterTags.add(PosterTag.fromJsonAll(entry));
    }
  }

  PosterTags(this.posterTags);
}

class PosterTagsLists {
  List<PosterTag> posterCampaign;
  List<PosterTag> posterType;
  List<PosterTag> posterMotive;
  List<PosterTag> posterTargetGroups;
  List<PosterTag> posterEnvironment;
  List<PosterTag> posterOther;

  PosterTagsLists.fromJson(Map<String, dynamic> json)
      : this.posterCampaign =
      PosterTags
          .fromJson(json['poster_campaign'])
          .posterTags,
        this.posterType = PosterTags
            .fromJson(json['poster_type'])
            .posterTags,
        this.posterMotive =
            PosterTags
                .fromJson(json['poster_motive'])
                .posterTags,
        this.posterTargetGroups =
            PosterTags
                .fromJson(json['poster_target_groups'])
                .posterTags,
        this.posterEnvironment =
            PosterTags
                .fromJson(json['poster_environment'])
                .posterTags,
        this.posterOther = PosterTags
            .fromJson(json['poster_other'])
            .posterTags;

  PosterTagsLists(this.posterCampaign, this.posterType, this.posterMotive,
      this.posterTargetGroups, this.posterEnvironment, this.posterOther);

  static empty() {
    return PosterTagsLists([], [], [], [], [], []);
  }
}
