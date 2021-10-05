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

  /// `Load all Posters`
  String get posterLoadAll {
    return Intl.message(
      'Load all Posters',
      name: 'posterLoadAll',
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

  /// `Load Posters changed after:`
  String get posterUpdateAfterDateSelection {
    return Intl.message(
      'Load Posters changed after:',
      name: 'posterUpdateAfterDateSelection',
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
