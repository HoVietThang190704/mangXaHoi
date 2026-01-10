import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'facebook'**
  String get facebook;

  /// No description provided for @hint_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get hint_name;

  /// No description provided for @hint_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get hint_password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @create_account_text.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get create_account_text;

  /// No description provided for @register_prompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get register_prompt;

  /// No description provided for @name_label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get name_label;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirm_password;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get register_success;

  /// No description provided for @hint_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hint_email;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to log in. Please try again.'**
  String get login_error;

  /// No description provided for @register_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to register. Please try again.'**
  String get register_error;

  /// No description provided for @password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_mismatch;

  /// No description provided for @email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_required;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_required;

  /// No description provided for @email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get email_invalid;

  /// No description provided for @name_required.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get name_required;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_too_short;

  /// No description provided for @confirm_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirm_password_required;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get login_success;

  /// No description provided for @login_first.
  ///
  /// In en, this message translates to:
  /// **'Please log in to post'**
  String get login_first;

  /// No description provided for @video_not_supported.
  ///
  /// In en, this message translates to:
  /// **'Video upload is not supported yet'**
  String get video_not_supported;

  /// No description provided for @create_post_hint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get create_post_hint;

  /// No description provided for @create_post_title.
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get create_post_title;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get language_vietnamese;

  /// No description provided for @create_post_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to publish post. Please try again.'**
  String get create_post_error;

  /// No description provided for @privacy_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get privacy_public;

  /// No description provided for @privacy_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get privacy_friends;

  /// No description provided for @privacy_private.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get privacy_private;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @tag_people.
  ///
  /// In en, this message translates to:
  /// **'Tag people'**
  String get tag_people;

  /// No description provided for @add_location.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get add_location;

  /// No description provided for @feeling_activity.
  ///
  /// In en, this message translates to:
  /// **'Feeling/activity'**
  String get feeling_activity;

  /// No description provided for @create_event.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get create_event;

  /// No description provided for @search_title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_title;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get search_hint;

  /// No description provided for @search_no_results.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get search_no_results;

  /// No description provided for @search_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to search users. Please try again.'**
  String get search_error;

  /// No description provided for @search_min_chars.
  ///
  /// In en, this message translates to:
  /// **'Please type at least 2 characters'**
  String get search_min_chars;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_search.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settings_search;

  /// No description provided for @settings_account_center.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT CENTER'**
  String get settings_account_center;

  /// No description provided for @settings_help_feedback.
  ///
  /// In en, this message translates to:
  /// **'HELP & FEEDBACK'**
  String get settings_help_feedback;

  /// No description provided for @settings_options.
  ///
  /// In en, this message translates to:
  /// **'OPTIONS'**
  String get settings_options;

  /// No description provided for @settings_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settings_edit_profile;

  /// No description provided for @settings_edit_profile_desc.
  ///
  /// In en, this message translates to:
  /// **'Update name, address and personal info'**
  String get settings_edit_profile_desc;

  /// No description provided for @settings_contact.
  ///
  /// In en, this message translates to:
  /// **'Update contact'**
  String get settings_contact;

  /// No description provided for @settings_contact_desc.
  ///
  /// In en, this message translates to:
  /// **'Manage your social links'**
  String get settings_contact_desc;

  /// No description provided for @settings_security.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get settings_security;

  /// No description provided for @settings_security_desc.
  ///
  /// In en, this message translates to:
  /// **'Change password and security'**
  String get settings_security_desc;

  /// No description provided for @settings_feedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get settings_feedback;

  /// No description provided for @settings_feedback_desc.
  ///
  /// In en, this message translates to:
  /// **'Share your ideas and suggestions'**
  String get settings_feedback_desc;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_desc.
  ///
  /// In en, this message translates to:
  /// **'Change display language'**
  String get settings_language_desc;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settings_logout;

  /// No description provided for @settings_logout_desc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of the current account'**
  String get settings_logout_desc;

  /// No description provided for @settings_logout_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settings_logout_confirm_title;

  /// No description provided for @settings_logout_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settings_logout_confirm_message;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get common_saving;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profile_title;

  /// No description provided for @profile_display_name.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profile_display_name;

  /// No description provided for @profile_display_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profile_display_name_hint;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profile_phone;

  /// No description provided for @profile_phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get profile_phone_hint;

  /// No description provided for @profile_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profile_address;

  /// No description provided for @profile_address_hint.
  ///
  /// In en, this message translates to:
  /// **'Street, city'**
  String get profile_address_hint;

  /// No description provided for @profile_save_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profile_save_success;

  /// No description provided for @profile_phone_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone (e.g., 098xxxxxxx)'**
  String get profile_phone_invalid;

  /// No description provided for @contact_title.
  ///
  /// In en, this message translates to:
  /// **'Update contact'**
  String get contact_title;

  /// No description provided for @contact_save_success.
  ///
  /// In en, this message translates to:
  /// **'Contact info saved'**
  String get contact_save_success;

  /// No description provided for @security_title.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get security_title;

  /// No description provided for @security_current_password.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get security_current_password;

  /// No description provided for @security_new_password.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get security_new_password;

  /// No description provided for @security_confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get security_confirm_new_password;

  /// No description provided for @security_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'New password does not match'**
  String get security_password_mismatch;

  /// No description provided for @security_save_success.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get security_save_success;

  /// No description provided for @language_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_title;

  /// No description provided for @language_vi.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get language_vi;

  /// No description provided for @language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_en;

  /// No description provided for @language_save_success.
  ///
  /// In en, this message translates to:
  /// **'Language updated. Restart if not applied.'**
  String get language_save_success;

  /// No description provided for @language_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update language: {error}'**
  String language_save_failed(Object error);

  /// No description provided for @feedback_title.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback_title;

  /// No description provided for @feedback_hint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think...'**
  String get feedback_hint;

  /// No description provided for @feedback_optional_email.
  ///
  /// In en, this message translates to:
  /// **'Contact email (optional)'**
  String get feedback_optional_email;

  /// No description provided for @feedback_sent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent. Thank you!'**
  String get feedback_sent;

  /// No description provided for @feedback_send.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedback_send;

  /// No description provided for @feedback_sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get feedback_sending;

  /// No description provided for @feedback_required.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty'**
  String get feedback_required;

  /// No description provided for @feedback_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to send feedback: {error}'**
  String feedback_failed(Object error);

  /// No description provided for @profile_feed_empty.
  ///
  /// In en, this message translates to:
  /// **'No posts to display.'**
  String get profile_feed_empty;

  /// No description provided for @profile_login_required_title.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in'**
  String get profile_login_required_title;

  /// No description provided for @profile_login_required_body.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your profile.'**
  String get profile_login_required_body;

  /// No description provided for @profile_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get profile_retry;

  /// No description provided for @profile_error_title.
  ///
  /// In en, this message translates to:
  /// **'Unable to load content'**
  String get profile_error_title;

  /// No description provided for @profile_edit_cover.
  ///
  /// In en, this message translates to:
  /// **'Edit cover photo'**
  String get profile_edit_cover;

  /// No description provided for @profile_add_to_story.
  ///
  /// In en, this message translates to:
  /// **'Add to story'**
  String get profile_add_to_story;

  /// No description provided for @profile_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profile_edit_profile;

  /// No description provided for @profile_tab_posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profile_tab_posts;

  /// No description provided for @profile_tab_photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get profile_tab_photos;

  /// No description provided for @profile_tab_reels.
  ///
  /// In en, this message translates to:
  /// **'Reels'**
  String get profile_tab_reels;

  /// No description provided for @profile_friend_count.
  ///
  /// In en, this message translates to:
  /// **'{count} friends'**
  String profile_friend_count(int count);

  /// No description provided for @profile_section_about.
  ///
  /// In en, this message translates to:
  /// **'Intro'**
  String get profile_section_about;

  /// No description provided for @profile_about_empty.
  ///
  /// In en, this message translates to:
  /// **'No introduction yet.'**
  String get profile_about_empty;

  /// No description provided for @profile_section_photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get profile_section_photos;

  /// No description provided for @profile_photos_empty.
  ///
  /// In en, this message translates to:
  /// **'No shared photos yet.'**
  String get profile_photos_empty;

  /// No description provided for @profile_view_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get profile_view_all;

  /// No description provided for @profile_section_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profile_section_friends;

  /// No description provided for @profile_friends_empty.
  ///
  /// In en, this message translates to:
  /// **'No friends list available.'**
  String get profile_friends_empty;

  /// No description provided for @profile_default_display_name.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profile_default_display_name;

  /// No description provided for @profile_user_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_user_title;

  /// No description provided for @profile_add_friend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get profile_add_friend;

  /// No description provided for @profile_cancel_request.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get profile_cancel_request;

  /// No description provided for @profile_remove_friend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get profile_remove_friend;

  /// No description provided for @profile_friend_request_sent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get profile_friend_request_sent;

  /// No description provided for @profile_friend_request_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Friend request cancelled'**
  String get profile_friend_request_cancelled;

  /// No description provided for @profile_friend_removed.
  ///
  /// In en, this message translates to:
  /// **'Removed from friends'**
  String get profile_friend_removed;

  /// No description provided for @profile_friend_request_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update friendship. Please try again.'**
  String get profile_friend_request_failed;

  /// No description provided for @profile_message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get profile_message;

  /// No description provided for @profile_message_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot start a chat right now.'**
  String get profile_message_unavailable;

  /// No description provided for @profile_like_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to update likes.'**
  String get profile_like_error;

  /// No description provided for @profile_invalid_user_data.
  ///
  /// In en, this message translates to:
  /// **'No valid user data found.'**
  String get profile_invalid_user_data;

  /// No description provided for @profile_avatar_take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profile_avatar_take_photo;

  /// No description provided for @profile_avatar_choose_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profile_avatar_choose_gallery;

  /// No description provided for @profile_avatar_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profile_avatar_updated;

  /// **'Unable to update profile photo.'**
  String get profile_avatar_update_failed;

  /// No description provided for @post_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Post detail'**
  String get post_detail_title;

  /// No description provided for @comment_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get comment_input_hint;

  /// No description provided for @replying_to.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String replying_to(String name);

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @comments_empty.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get comments_empty;

  /// No description provided for @comment_like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get comment_like;

  /// No description provided for @comment_reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get comment_reply;

  /// No description provided for @comment_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load comments'**
  String get comment_load_failed;

  /// No description provided for @comment_like_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to like comment'**
  String get comment_like_failed;

  /// No description provided for @comment_action_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to post comment'**
  String get comment_action_failed;

  /// No description provided for @max_reply_depth.
  ///
  /// In en, this message translates to:
  /// **'Only 3 levels of replies are supported'**
  String get max_reply_depth;

  /// No description provided for @delete_comment_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_comment_confirm_title;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
