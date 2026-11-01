// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appName => 'NIPANGE';

  @override
  String get home => 'Nyumbani';

  @override
  String get discover => 'Gundua';

  @override
  String get create => 'Tengeneza';

  @override
  String get chats => 'Chats';

  @override
  String get profile => 'Wasifu';

  @override
  String get search => 'Tafuta';

  @override
  String get notifications => 'Arifa';

  @override
  String get settings => 'Mipangilio';

  @override
  String get welcome => 'Karibu — jiunge au ingia';

  @override
  String get verify => 'Ingiza namba ya kuthibitisha';

  @override
  String get phone => 'Namba ya simu (+255…)';

  @override
  String get password => 'Nenosiri';

  @override
  String get otp => '——————';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get signIn => 'Ingia';

  @override
  String get join => 'Jiunge';

  @override
  String get noAccount => 'Huna akaunti? Jiunge';

  @override
  String get hasAccount => 'Tayari una akaunti? Ingia';

  @override
  String resendIn(Object s) {
    return 'Tuma tena baada ya ${s}s';
  }

  @override
  String get resendNow => 'Tuma namba tena';

  @override
  String get emptyFeed => 'Hakuna posts bado — uwe wa kwanza!';

  @override
  String get loadFailed => 'Imeshindikana kupakia feed';

  @override
  String get retry => 'Jaribu tena';

  @override
  String get noChats => 'Hakuna mazungumzo bado';

  @override
  String get logout => 'Toka';

  @override
  String get createPost => 'Tengeneza';

  @override
  String get createSheetPost => 'Post ya maandishi';

  @override
  String get createSheetPhoto => 'Picha';

  @override
  String get createSheetReel => 'Reel';

  @override
  String get createSheetStory => 'Story';

  @override
  String get createSheetPoll => 'Poll';
}
