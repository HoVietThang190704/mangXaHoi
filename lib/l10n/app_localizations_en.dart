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

  @override
  String get login_first => 'Please log in to post';

  @override
  String get video_not_supported => 'Video upload is not supported yet';

  @override
  String get search_title => 'Search';

  @override
  String get search_hint => 'Search users';

  @override
  String get search_no_results => 'No users found';

  @override
  String get search_error => 'Unable to search users. Please try again.';

  @override
  String get search_min_chars => 'Please type at least 2 characters';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_search => 'Search settings';

  @override
  String get settings_account_center => 'ACCOUNT CENTER';

  @override
  String get settings_help_feedback => 'HELP & FEEDBACK';

  @override
  String get settings_options => 'OPTIONS';

  @override
  String get settings_edit_profile => 'Edit profile';

  @override
  String get settings_edit_profile_desc => 'Update name, address and personal info';

  @override
  String get settings_contact => 'Update contact';

  @override
  String get settings_contact_desc => 'Manage your social links';

  @override
  String get settings_security => 'Account security';

  @override
  String get settings_security_desc => 'Change password and security';

  @override
  String get settings_feedback => 'Send feedback';

  @override
  String get settings_feedback_desc => 'Share your ideas and suggestions';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_desc => 'Change display language';

  @override
  String get settings_logout => 'Log out';

  @override
  String get settings_logout_desc => 'Sign out of the current account';

  @override
  String get settings_logout_confirm_title => 'Log out';

  @override
  String get settings_logout_confirm_message => 'Are you sure you want to log out?';

  @override
  String get language_english => 'English';

  @override
  String get language_vietnamese => 'Vietnamese';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_save => 'Save';

  @override
  String get common_saving => 'Saving...';

  @override
  String get profile_title => 'Edit profile';

  @override
  String get profile_display_name => 'Display name';

  @override
  String get profile_display_name_hint => 'Enter your name';

  @override
  String get profile_phone => 'Phone number';

  @override
  String get profile_phone_hint => 'Enter phone number';

  @override
  String get profile_address => 'Address';

  @override
  String get profile_address_hint => 'Street, city';

  @override
  String get profile_save_success => 'Profile updated';

  @override
  String get profile_phone_invalid => 'Invalid phone (e.g., 098xxxxxxx)';

  @override
  String get contact_title => 'Update contact';

  @override
  String get contact_save_success => 'Contact info saved';

  @override
  String get security_title => 'Account security';

  @override
  String get security_current_password => 'Current password';

  @override
  String get security_new_password => 'New password';

  @override
  String get security_confirm_new_password => 'Confirm new password';

  @override
  String get security_password_mismatch => 'New password does not match';

  @override
  String get security_save_success => 'Password changed';

  @override
  String get language_title => 'Language';

  @override
  String get language_vi => 'Vietnamese';

  @override
  String get language_en => 'English';

  @override
  String get language_save_success => 'Language updated. Restart if not applied.';

  @override
  String language_save_failed(Object error) {
    return 'Failed to update language: $error';
  }

  @override
  String get feedback_title => 'Feedback';

  @override
  String get feedback_hint => 'Tell us what you think...';

  @override
  String get feedback_optional_email => 'Contact email (optional)';

  @override
  String get feedback_sent => 'Feedback sent. Thank you!';

  @override
  String get feedback_send => 'Send feedback';

  @override
  String get feedback_sending => 'Sending...';

  @override
  String get feedback_required => 'Message cannot be empty';

  @override
  String feedback_failed(Object error) {
    return 'Unable to send feedback: $error';
  }

  @override
  String get create_post_error => 'Unable to create post';

  @override
  String get create_post_title => 'Create post';

  @override
  String get create_post_hint => 'What\'s on your mind?';

  @override
  String get post => 'Post';

  @override
  String get privacy_public => 'Public';

  @override
  String get privacy_friends => 'Friends';

  @override
  String get privacy_private => 'Only me';

  @override
  String get photo => 'Photo';

  @override
  String get video => 'Video';

  @override
  String get tag_people => 'Tag people';

  @override
  String get add_location => 'Check in';

  @override
  String get feeling_activity => 'Feeling/activity';

  @override
  String get create_event => 'Create event';

  @override
  String get cancel => 'Cancel';

  @override
  String get unknown => 'Unknown';

  @override
  String get comments => 'Comments';

  @override
  String get post_detail_title => 'Post detail';

  @override
  String get comment_input_hint => 'Write a comment...';

  @override
  String replying_to(String name) {
    return 'Replying to $name';
  }

  @override
  String get send => 'Send';

  @override
  String get comments_empty => 'No comments yet';

  @override
  String get comment_like => 'Like';

  @override
  String get comment_reply => 'Reply';

  @override
  String get comment_load_failed => 'Unable to load comments';

  @override
  String get comment_like_failed => 'Unable to like comment';

  @override
  String get comment_action_failed => 'Unable to post comment';

  @override
  String get max_reply_depth => 'Only 3 levels of replies are supported';

  @override
  String get delete_comment_confirm_title => 'Delete';
}
