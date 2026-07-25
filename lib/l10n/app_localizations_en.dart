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
  String get confirmPassword => 'Confirm password';

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
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordDescription =>
      'Enter your email address and we will send you a reset link if an account exists.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Please enter a valid phone number';

  @override
  String get invalidEmailFormat => 'Please enter a valid email address';

  @override
  String get weakPassword =>
      'Password must be at least 8 characters and contain at least 1 digit';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordResetSent =>
      'If an account exists for this email, a reset link has been sent.';

  @override
  String get passwordResetCheckEmailTitle => 'Check your email';

  @override
  String get passwordResetNextSteps =>
      'Open the reset link in your email, set a new password, then sign in with it.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get signInWithNewPassword =>
      'If you updated your password, sign in with your new password.';

  @override
  String get verifyEmailBanner => 'Please verify your email';

  @override
  String get resendVerificationEmail => 'Resend email';

  @override
  String get verificationEmailSent => 'Verification email sent';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Resend available in ${seconds}s';
  }

  @override
  String get dismissEmailVerificationBanner =>
      'Dismiss email verification reminder';

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

  @override
  String get retry => 'Retry';

  @override
  String get splashConnectionIssueTitle => 'Connection problem';

  @override
  String get splashConnectionIssueMessage =>
      'We could not verify your session. Check your internet connection and try again.';

  @override
  String get homeTab => 'Home';

  @override
  String get ordersTab => 'Orders';

  @override
  String get newOrderTab => 'New';

  @override
  String get profileTab => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get availableOrdersTab => 'Orders';

  @override
  String get activeDeliveryTab => 'Active';

  @override
  String get earningsTab => 'Earnings';

  @override
  String get adminDashboardTab => 'Dashboard';

  @override
  String get adminOrdersTab => 'Orders';

  @override
  String get adminCouriersTab => 'Couriers';

  @override
  String get createNewOrder => 'Create new order';

  @override
  String get activeOrderOnTheWay => 'Order on the way';

  @override
  String activeOrderEta(int minutes) {
    return 'Courier arrives in $minutes min';
  }

  @override
  String get recentSectionTitle => 'Recent';

  @override
  String get recentOrdersEmpty => 'No completed orders yet.';

  @override
  String get customerOrdersEmpty =>
      'No orders yet. Your delivery history will appear here.';

  @override
  String get ordersFilterHint => 'Filter orders';

  @override
  String get newOrderComingSoon => 'Order creation flow coming soon.';

  @override
  String get availableOrdersEmpty => 'No open orders nearby right now.';

  @override
  String get courierSearchHint => 'Search available orders';

  @override
  String get activeDeliveryEmpty =>
      'No active delivery. Accept an order to start.';

  @override
  String get activeDeliveryNoteHint => 'Delivery note';

  @override
  String get earningsEmpty =>
      'No earnings yet. Completed deliveries will appear here.';

  @override
  String get adminDashboardEmpty => 'Live map dashboard coming soon.';

  @override
  String get adminOrdersEmpty => 'No orders to manage yet.';

  @override
  String get adminCouriersEmpty => 'No couriers to display yet.';

  @override
  String get mapUnavailable =>
      'Map unavailable. Add your 2GIS key to assets/keys/dgissdk.key or enter addresses manually.';

  @override
  String get newOrderPickupSection => 'Pickup';

  @override
  String get newOrderDropoffSection => 'Drop-off';

  @override
  String get pickupAddressLabel => 'Pickup address';

  @override
  String get dropoffAddressLabel => 'Drop-off address';

  @override
  String get orderNoteLabel => 'Package note (optional)';

  @override
  String get createOrderButton => 'Create order';

  @override
  String get pickFromMapPickup => 'Use map center for pickup';

  @override
  String get pickFromMapDropoff => 'Use map center for drop-off';

  @override
  String get orderStatusCreated => 'Created';

  @override
  String get orderStatusAccepted => 'Accepted';

  @override
  String get orderStatusPickedUp => 'Picked up';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';
}
