// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get facebook => 'facebook';

  @override
  String get hint_name => 'Name';

  @override
  String get hint_password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgot_password => 'Forgot password?';

  @override
  String get create_account_text => 'Create a new account';

  @override
  String get register_prompt => 'Already have an account? Login';

  @override
  String get name_label => 'Full name';

  @override
  String get email_label => 'Email';

  @override
  String get confirm_password => 'Confirm password';

  @override
  String get register_success => 'Registration successful';

  @override
  String get hint_email => 'Email';

  @override
  String get login_error => 'Unable to log in. Please try again.';

  @override
  String get register_error => 'Unable to register. Please try again.';

  @override
  String get password_mismatch => 'Passwords do not match';

  @override
  String get email_required => 'Email is required';

  @override
  String get password_required => 'Password is required';

  @override
  String get email_invalid => 'Invalid email address';

  @override
  String get name_required => 'Full name is required';

  @override
  String get password_too_short => 'Password must be at least 6 characters';

  @override
  String get confirm_password_required => 'Please confirm your password';

  @override
  String get login_success => 'Logged in successfully';
}
