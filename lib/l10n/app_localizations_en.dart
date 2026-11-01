// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NIPANGE';

  @override
  String get home => 'Home';

  @override
  String get discover => 'Discover';

  @override
  String get create => 'Create';

  @override
  String get chats => 'Chats';

  @override
  String get profile => 'Profile';

  @override
  String get search => 'Search';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get welcome => 'Welcome — join or sign in';

  @override
  String get verify => 'Enter the verification code';

  @override
  String get phone => 'Phone number (+255…)';

  @override
  String get password => 'Password';

  @override
  String get otp => '——————';

  @override
  String get confirm => 'Confirm';

  @override
  String get signIn => 'Sign in';

  @override
  String get join => 'Join';

  @override
  String get noAccount => 'No account? Join';

  @override
  String get hasAccount => 'Have an account? Sign in';

  @override
  String resendIn(Object s) {
    return 'Resend in ${s}s';
  }

  @override
  String get resendNow => 'Resend code';

  @override
  String get emptyFeed => 'No posts yet — be the first!';

  @override
  String get loadFailed => 'Failed to load feed';

  @override
  String get retry => 'Try again';

  @override
  String get noChats => 'No conversations yet';

  @override
  String get logout => 'Logout';

  @override
  String get createPost => 'Create';

  @override
  String get createSheetPost => 'Text post';

  @override
  String get createSheetPhoto => 'Photo';

  @override
  String get createSheetReel => 'Reel';

  @override
  String get createSheetStory => 'Story';

  @override
  String get createSheetPoll => 'Poll';
}
