// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Volt Campaigner`
  String get appTitle {
    return Intl.message(
      'Volt Campaigner',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add Poster`
  String get addPoster {
    return Intl.message(
      'Add Poster',
      name: 'addPoster',
      desc: '',
      args: [],
    );
  }

  /// `Poster`
  String get poster {
    return Intl.message(
      'Poster',
      name: 'poster',
      desc: '',
      args: [],
    );
  }

  /// `Flyer`
  String get flyer {
    return Intl.message(
      'Flyer',
      name: 'flyer',
      desc: '',
      args: [],
    );
  }

  /// `Areas`
  String get areas {
    return Intl.message(
      'Areas',
      name: 'areas',
      desc: '',
      args: [],
    );
  }

  /// `Volunteer invite`
  String get volunteer {
    return Intl.message(
      'Volunteer invite',
      name: 'volunteer',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get statistics {
    return Intl.message(
      'Statistics',
      name: 'statistics',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Poster-Type`
  String get posterType {
    return Intl.message(
      'Poster-Type',
      name: 'posterType',
      desc: '',
      args: [],
    );
  }

  /// `Motive`
  String get posterMotive {
    return Intl.message(
      'Motive',
      name: 'posterMotive',
      desc: '',
      args: [],
    );
  }

  /// `Target-Groups`
  String get posterTargetGroups {
    return Intl.message(
      'Target-Groups',
      name: 'posterTargetGroups',
      desc: '',
      args: [],
    );
  }

  /// `Environment`
  String get posterEnvironment {
    return Intl.message(
      'Environment',
      name: 'posterEnvironment',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get posterOther {
    return Intl.message(
      'Other',
      name: 'posterOther',
      desc: '',
      args: [],
    );
  }

  /// `Kampagne`
  String get posterCampaign {
    return Intl.message(
      'Kampagne',
      name: 'posterCampaign',
      desc: '',
      args: [],
    );
  }

  /// `Add Poster`
  String get posterAdd {
    return Intl.message(
      'Add Poster',
      name: 'posterAdd',
      desc: '',
      args: [],
    );
  }

  /// `Could not add Poster`
  String get errorAddPoster {
    return Intl.message(
      'Could not add Poster',
      name: 'errorAddPoster',
      desc: '',
      args: [],
    );
  }

  /// `Unhang Poster`
  String get posterUnhang {
    return Intl.message(
      'Unhang Poster',
      name: 'posterUnhang',
      desc: '',
      args: [],
    );
  }

  /// `Edit Poster`
  String get posterEdit {
    return Intl.message(
      'Edit Poster',
      name: 'posterEdit',
      desc: '',
      args: [],
    );
  }

  /// `Recycle Poster`
  String get posterRecycle {
    return Intl.message(
      'Recycle Poster',
      name: 'posterRecycle',
      desc: '',
      args: [],
    );
  }

  /// `Could not edit Poster`
  String get errorEditPoster {
    return Intl.message(
      'Could not edit Poster',
      name: 'errorEditPoster',
      desc: '',
      args: [],
    );
  }

  /// `Could not load Posters`
  String get errorFetchingPosterLocations {
    return Intl.message(
      'Could not load Posters',
      name: 'errorFetchingPosterLocations',
      desc: '',
      args: [],
    );
  }

  /// `Load Posters in Radius of `
  String get posterRadius {
    return Intl.message(
      'Load Posters in Radius of ',
      name: 'posterRadius',
      desc: '',
      args: [],
    );
  }

  /// `Load Flyers in Radius of `
  String get flyerRadius {
    return Intl.message(
      'Load Flyers in Radius of ',
      name: 'flyerRadius',
      desc: '',
      args: [],
    );
  }

  /// `Load Areas in Radius of `
  String get areasRadius {
    return Intl.message(
      'Load Areas in Radius of ',
      name: 'areasRadius',
      desc: '',
      args: [],
    );
  }

  /// `Load all Posters`
  String get posterLoadAll {
    return Intl.message(
      'Load all Posters',
      name: 'posterLoadAll',
      desc: '',
      args: [],
    );
  }

  /// `Load all Flyers`
  String get flyerLoadAll {
    return Intl.message(
      'Load all Flyers',
      name: 'flyerLoadAll',
      desc: '',
      args: [],
    );
  }

  /// `Load all Areas`
  String get areasLoadAll {
    return Intl.message(
      'Load all Areas',
      name: 'areasLoadAll',
      desc: '',
      args: [],
    );
  }

  /// `Show current Areas on Map`
  String get showAreasOnMap {
    return Intl.message(
      'Show current Areas on Map',
      name: 'showAreasOnMap',
      desc: '',
      args: [],
    );
  }

  /// `Load Posters that are `
  String get posterHanginDescription {
    return Intl.message(
      'Load Posters that are ',
      name: 'posterHanginDescription',
      desc: '',
      args: [],
    );
  }

  /// `hanging`
  String get posterHangingStatus {
    return Intl.message(
      'hanging',
      name: 'posterHangingStatus',
      desc: '',
      args: [],
    );
  }

  /// `unhanged`
  String get posterUnhangStatus {
    return Intl.message(
      'unhanged',
      name: 'posterUnhangStatus',
      desc: '',
      args: [],
    );
  }

  /// `recycled`
  String get posterRecycleStatus {
    return Intl.message(
      'recycled',
      name: 'posterRecycleStatus',
      desc: '',
      args: [],
    );
  }

  /// `Custom Date`
  String get posterCustomDate {
    return Intl.message(
      'Custom Date',
      name: 'posterCustomDate',
      desc: '',
      args: [],
    );
  }

  /// `Custom Date`
  String get flyerCustomDate {
    return Intl.message(
      'Custom Date',
      name: 'flyerCustomDate',
      desc: '',
      args: [],
    );
  }

  /// `Custom Date`
  String get areasCustomDate {
    return Intl.message(
      'Custom Date',
      name: 'areasCustomDate',
      desc: '',
      args: [],
    );
  }

  /// `Load Posters changed after:`
  String get posterUpdateAfterDateSelection {
    return Intl.message(
      'Load Posters changed after:',
      name: 'posterUpdateAfterDateSelection',
      desc: '',
      args: [],
    );
  }

  /// `Load Flyer changed after:`
  String get flyerUpdateAfterDateSelection {
    return Intl.message(
      'Load Flyer changed after:',
      name: 'flyerUpdateAfterDateSelection',
      desc: '',
      args: [],
    );
  }

  /// `Load Areas changed after:`
  String get areasUpdateAfterDateSelection {
    return Intl.message(
      'Load Areas changed after:',
      name: 'areasUpdateAfterDateSelection',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Draw line to nearest Poster`
  String get drawNearestPosterLine {
    return Intl.message(
      'Draw line to nearest Poster',
      name: 'drawNearestPosterLine',
      desc: '',
      args: [],
    );
  }

  /// `Place marker by hand`
  String get placeMarkerByHand {
    return Intl.message(
      'Place marker by hand',
      name: 'placeMarkerByHand',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `No Data`
  String get noData {
    return Intl.message(
      'No Data',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get export {
    return Intl.message(
      'Export',
      name: 'export',
      desc: '',
      args: [],
    );
  }

  /// `Export as `
  String get exportAs {
    return Intl.message(
      'Export as ',
      name: 'exportAs',
      desc: '',
      args: [],
    );
  }

  /// `Successfully exported into your Downloads Folder`
  String get successExport {
    return Intl.message(
      'Successfully exported into your Downloads Folder',
      name: 'successExport',
      desc: '',
      args: [],
    );
  }

  /// `Could not Login into API`
  String get errorLogin {
    return Intl.message(
      'Could not Login into API',
      name: 'errorLogin',
      desc: '',
      args: [],
    );
  }

  /// `Please let your Display on! If not we cannot collect your route! You can darken your Display to save Energy`
  String get letDisplayEnabled {
    return Intl.message(
      'Please let your Display on! If not we cannot collect your route! You can darken your Display to save Energy',
      name: 'letDisplayEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Give this QR Code to a Volunteer, so he can scan it and login too.`
  String get scanThisVolunteer {
    return Intl.message(
      'Give this QR Code to a Volunteer, so he can scan it and login too.',
      name: 'scanThisVolunteer',
      desc: '',
      args: [],
    );
  }

  /// `Or copy this and send it to the Volunteer`
  String get volunteerCopy {
    return Intl.message(
      'Or copy this and send it to the Volunteer',
      name: 'volunteerCopy',
      desc: '',
      args: [],
    );
  }

  /// `Copied text`
  String get copySuccess {
    return Intl.message(
      'Copied text',
      name: 'copySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Pasted text`
  String get pasteSuccess {
    return Intl.message(
      'Pasted text',
      name: 'pasteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Scan an invite code from a member`
  String get scanCodeVolunteer {
    return Intl.message(
      'Scan an invite code from a member',
      name: 'scanCodeVolunteer',
      desc: '',
      args: [],
    );
  }

  /// `or enter Code here`
  String get orEnterCode {
    return Intl.message(
      'or enter Code here',
      name: 'orEnterCode',
      desc: '',
      args: [],
    );
  }

  /// `Invalid oder retired Code`
  String get invalidToken {
    return Intl.message(
      'Invalid oder retired Code',
      name: 'invalidToken',
      desc: '',
      args: [],
    );
  }

  /// `Login with your Volt Europa Account`
  String get loginVoltEuropa {
    return Intl.message(
      'Login with your Volt Europa Account',
      name: 'loginVoltEuropa',
      desc: '',
      args: [],
    );
  }

  /// `Login as Volunteer`
  String get loginAsVolunteer {
    return Intl.message(
      'Login as Volunteer',
      name: 'loginAsVolunteer',
      desc: '',
      args: [],
    );
  }

  /// `Could not add Area`
  String get errorAddArea {
    return Intl.message(
      'Could not add Area',
      name: 'errorAddArea',
      desc: '',
      args: [],
    );
  }

  /// `Save Area`
  String get addArea {
    return Intl.message(
      'Save Area',
      name: 'addArea',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Max Poster Count`
  String get maxPosterCount {
    return Intl.message(
      'Max Poster Count',
      name: 'maxPosterCount',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Bist du dir sicher, dass du das löschen möchtest?`
  String get sureDelete {
    return Intl.message(
      'Bist du dir sicher, dass du das löschen möchtest?',
      name: 'sureDelete',
      desc: '',
      args: [],
    );
  }

  /// `Maximum`
  String get max {
    return Intl.message(
      'Maximum',
      name: 'max',
      desc: '',
      args: [],
    );
  }

  /// `Hanging`
  String get hanging {
    return Intl.message(
      'Hanging',
      name: 'hanging',
      desc: '',
      args: [],
    );
  }

  /// `Color marker by`
  String get colorMarker {
    return Intl.message(
      'Color marker by',
      name: 'colorMarker',
      desc: '',
      args: [],
    );
  }

  /// `Fiter marker by`
  String get filterMarker {
    return Intl.message(
      'Fiter marker by',
      name: 'filterMarker',
      desc: '',
      args: [],
    );
  }

  /// `Here you can add posters and give them tags so we can identify what posters are hanging where`
  String get featureAddPosterDescription {
    return Intl.message(
      'Here you can add posters and give them tags so we can identify what posters are hanging where',
      name: 'featureAddPosterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Here you can search for a city or a location`
  String get featureSearchDescription {
    return Intl.message(
      'Here you can search for a city or a location',
      name: 'featureSearchDescription',
      desc: '',
      args: [],
    );
  }

  /// `Allowed Posters`
  String get featureLimit {
    return Intl.message(
      'Allowed Posters',
      name: 'featureLimit',
      desc: '',
      args: [],
    );
  }

  /// `Here you see the limits of your current area, how many posters are hanging and how many are allowed`
  String get featureLimitDescription {
    return Intl.message(
      'Here you see the limits of your current area, how many posters are hanging and how many are allowed',
      name: 'featureLimitDescription',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get featureRefresh {
    return Intl.message(
      'Refresh',
      name: 'featureRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Here can you refresh the data and teleport to your location on the map`
  String get featureRefreshDescription {
    return Intl.message(
      'Here can you refresh the data and teleport to your location on the map',
      name: 'featureRefreshDescription',
      desc: '',
      args: [],
    );
  }

  /// `Zoom in`
  String get featureZoomIn {
    return Intl.message(
      'Zoom in',
      name: 'featureZoomIn',
      desc: '',
      args: [],
    );
  }

  /// `Here you can make the map bigger`
  String get featureZoomInDescription {
    return Intl.message(
      'Here you can make the map bigger',
      name: 'featureZoomInDescription',
      desc: '',
      args: [],
    );
  }

  /// `Zoom out`
  String get featureZoomOut {
    return Intl.message(
      'Zoom out',
      name: 'featureZoomOut',
      desc: '',
      args: [],
    );
  }

  /// `Here you can make the map smaller`
  String get featureZoomOutDescription {
    return Intl.message(
      'Here you can make the map smaller',
      name: 'featureZoomOutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Record route`
  String get featureRecordFlyer {
    return Intl.message(
      'Record route',
      name: 'featureRecordFlyer',
      desc: '',
      args: [],
    );
  }

  /// `Here you can record your route while flyering. Through this others can see where you allready have been. Attention! Dont lock your Display, because then we dont have access to the GPS data! We recommend to darken your display and take a powerbank with you.`
  String get featureRecordFlyerDescription {
    return Intl.message(
      'Here you can record your route while flyering. Through this others can see where you allready have been. Attention! Dont lock your Display, because then we dont have access to the GPS data! We recommend to darken your display and take a powerbank with you.',
      name: 'featureRecordFlyerDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
