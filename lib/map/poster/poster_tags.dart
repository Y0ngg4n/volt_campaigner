import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PosterTag {
  String id;
  String name;
  Color color;
  bool active;

  PosterTag(
      {required this.id,
      required this.name,
      required this.active,
      required this.color});

  toJson() {
    Map<String, dynamic> m = new Map();
    m['id'] = id;
    m['description'] = name;
    m['active'] = active;
    m['color'] = color.toHex();

    return m;
  }

  PosterTag.fromJson(String id)
      : id = id,
        name = "",
        active = true,
        color = Colors.purple;

  PosterTag.fromJsonAll(Map<String, dynamic> json)
      : id = json['id'],
        name = json['description_' + Intl.getCurrentLocale().substring(0, 2)] ??
            json['description_en'],
        active = json['active'],
        color = HexColor.fromHex(json['color'] ?? Colors.purple.toHex());
}

class PosterTags {
  List<PosterTag> posterTags = [];

  toJson() {
    List<Map<String, dynamic>> list = [];
    for (PosterTag entry in posterTags) {
      list.add(entry.toJson());
    }
    return list;
  }

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
      : this.posterCampaign = PosterTags.fromJson(json['campaign']).posterTags,
        this.posterType = PosterTags.fromJson(json['poster_type']).posterTags,
        this.posterMotive = PosterTags.fromJson(json['motive']).posterTags,
        this.posterTargetGroups =
            PosterTags.fromJson(json['target_groups']).posterTags,
        this.posterEnvironment =
            PosterTags.fromJson(json['environment']).posterTags,
        this.posterOther = PosterTags.fromJson(json['other']).posterTags;

  PosterTagsLists(this.posterCampaign, this.posterType, this.posterMotive,
      this.posterTargetGroups, this.posterEnvironment, this.posterOther);

  static empty() {
    return PosterTagsLists([], [], [], [], [], []);
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHexWithOpacity(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
