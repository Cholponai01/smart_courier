import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Courier'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

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

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a reset link if an account exists.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmailFormat;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and contain at least 1 digit'**
  String get weakPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link has been sent.'**
  String get passwordResetSent;

  /// No description provided for @passwordResetCheckEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get passwordResetCheckEmailTitle;

  /// No description provided for @passwordResetNextSteps.
  ///
  /// In en, this message translates to:
  /// **'Open the reset link in your email, set a new password, then sign in with it.'**
  String get passwordResetNextSteps;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @signInWithNewPassword.
  ///
  /// In en, this message translates to:
  /// **'If you updated your password, sign in with your new password.'**
  String get signInWithNewPassword;

  /// No description provided for @verifyEmailBanner.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email'**
  String get verifyEmailBanner;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendVerificationEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// No description provided for @resendVerificationCooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {seconds}s'**
  String resendVerificationCooldown(int seconds);

  /// No description provided for @dismissEmailVerificationBanner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss email verification reminder'**
  String get dismissEmailVerificationBanner;

  /// No description provided for @customerHome.
  ///
  /// In en, this message translates to:
  /// **'Customer Home'**
  String get customerHome;

  /// No description provided for @courierHome.
  ///
  /// In en, this message translates to:
  /// **'Courier Home'**
  String get courierHome;

  /// No description provided for @adminHome.
  ///
  /// In en, this message translates to:
  /// **'Admin Home'**
  String get adminHome;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @splashConnectionIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection problem'**
  String get splashConnectionIssueTitle;

  /// No description provided for @splashConnectionIssueMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your session. Check your internet connection and try again.'**
  String get splashConnectionIssueMessage;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @ordersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTab;

  /// No description provided for @newOrderTab.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newOrderTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @availableOrdersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get availableOrdersTab;

  /// No description provided for @activeDeliveryTab.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeDeliveryTab;

  /// No description provided for @earningsTab.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTab;

  /// No description provided for @adminDashboardTab.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboardTab;

  /// No description provided for @adminOrdersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminOrdersTab;

  /// No description provided for @adminCouriersTab.
  ///
  /// In en, this message translates to:
  /// **'Couriers'**
  String get adminCouriersTab;

  /// No description provided for @createNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Create new order'**
  String get createNewOrder;

  /// No description provided for @activeOrderOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Order on the way'**
  String get activeOrderOnTheWay;

  /// No description provided for @activeOrderEta.
  ///
  /// In en, this message translates to:
  /// **'Courier arrives in {minutes} min'**
  String activeOrderEta(int minutes);

  /// No description provided for @recentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentSectionTitle;

  /// No description provided for @recentOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed orders yet.'**
  String get recentOrdersEmpty;

  /// No description provided for @customerOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet. Your delivery history will appear here.'**
  String get customerOrdersEmpty;

  /// No description provided for @ordersFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter orders'**
  String get ordersFilterHint;

  /// No description provided for @newOrderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Order creation flow coming soon.'**
  String get newOrderComingSoon;

  /// No description provided for @availableOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open orders nearby right now.'**
  String get availableOrdersEmpty;

  /// No description provided for @courierSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search available orders'**
  String get courierSearchHint;

  /// No description provided for @activeDeliveryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active delivery. Accept an order to start.'**
  String get activeDeliveryEmpty;

  /// No description provided for @activeDeliveryNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Delivery note'**
  String get activeDeliveryNoteHint;

  /// No description provided for @earningsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No earnings yet. Completed deliveries will appear here.'**
  String get earningsEmpty;

  /// No description provided for @adminDashboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Live map dashboard coming soon.'**
  String get adminDashboardEmpty;

  /// No description provided for @adminOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders to manage yet.'**
  String get adminOrdersEmpty;

  /// No description provided for @adminCouriersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No couriers to display yet.'**
  String get adminCouriersEmpty;

  /// No description provided for @mapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map unavailable. Add your 2GIS key to assets/keys/dgissdk.key or enter addresses manually.'**
  String get mapUnavailable;

  /// No description provided for @newOrderPickupSection.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get newOrderPickupSection;

  /// No description provided for @newOrderDropoffSection.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get newOrderDropoffSection;

  /// No description provided for @pickupAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get pickupAddressLabel;

  /// No description provided for @dropoffAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop-off address'**
  String get dropoffAddressLabel;

  /// No description provided for @orderNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Package note (optional)'**
  String get orderNoteLabel;

  /// No description provided for @createOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Create order'**
  String get createOrderButton;

  /// No description provided for @pickFromMapPickup.
  ///
  /// In en, this message translates to:
  /// **'Use map center for pickup'**
  String get pickFromMapPickup;

  /// No description provided for @pickFromMapDropoff.
  ///
  /// In en, this message translates to:
  /// **'Use map center for drop-off'**
  String get pickFromMapDropoff;

  /// No description provided for @orderStatusCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get orderStatusCreated;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get orderStatusPickedUp;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
