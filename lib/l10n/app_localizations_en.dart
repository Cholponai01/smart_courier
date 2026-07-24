// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Courier';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get customerHome => 'Customer Home';

  @override
  String get courierHome => 'Courier Home';

  @override
  String get adminHome => 'Admin Home';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get logout => 'Logout';
}
