import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Souq Alkhair'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

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

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @chooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get chooseYourRole;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @ifYouDontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t have an account'**
  String get ifYouDontHaveAnAccount;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account'**
  String get alreadyHaveAnAccount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Souq Alkhair'**
  String get welcome;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'A platform designed to facilitate the process of donation and shopping by providing a reliable and secure environment for users.'**
  String get description;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @recipientDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive help and support from community'**
  String get recipientDescription;

  /// No description provided for @donorDescription.
  ///
  /// In en, this message translates to:
  /// **'Contribute and give to those in need'**
  String get donorDescription;

  /// No description provided for @donor.
  ///
  /// In en, this message translates to:
  /// **'Donor'**
  String get donor;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectYourRole;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// No description provided for @conditionBroken.
  ///
  /// In en, this message translates to:
  /// **'Broken'**
  String get conditionBroken;

  /// No description provided for @conditionSecondHand.
  ///
  /// In en, this message translates to:
  /// **'Second Hand'**
  String get conditionSecondHand;

  /// No description provided for @conditionMid.
  ///
  /// In en, this message translates to:
  /// **'Good (Mid)'**
  String get conditionMid;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'Brand New'**
  String get conditionNew;

  /// No description provided for @donationsAddTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get donationsAddTitleHint;

  /// No description provided for @donationsAddDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get donationsAddDescriptionHint;

  /// No description provided for @donationsAddCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get donationsAddCategoryLabel;

  /// No description provided for @donationsDeliveryOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Option'**
  String get donationsDeliveryOptionLabel;

  /// No description provided for @donationsDeliveryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get donationsDeliveryPersonal;

  /// No description provided for @donationsDeliveryCharity.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get donationsDeliveryCharity;

  /// No description provided for @donationsSelectCharityLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Charity'**
  String get donationsSelectCharityLabel;

  /// No description provided for @donationsConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get donationsConditionLabel;

  /// No description provided for @donationsAddImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get donationsAddImages;

  /// No description provided for @donationsSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get donationsSubmit;

  /// No description provided for @donationsDonationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Donation submitted'**
  String get donationsDonationSubmitted;

  /// No description provided for @donationsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a donation'**
  String get donationsSearchHint;

  /// No description provided for @donationsSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get donationsSearchTooltip;

  /// No description provided for @donations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get donations;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @myDonations.
  ///
  /// In en, this message translates to:
  /// **'My Donations'**
  String get myDonations;

  /// No description provided for @requestsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Requests not found'**
  String get requestsNotFound;

  /// No description provided for @statusPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get statusPendingReview;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusAssignedToCharity.
  ///
  /// In en, this message translates to:
  /// **'Assigned to charity'**
  String get statusAssignedToCharity;

  /// No description provided for @statusInWarehouse.
  ///
  /// In en, this message translates to:
  /// **'In warehouse'**
  String get statusInWarehouse;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusNotDelivered.
  ///
  /// In en, this message translates to:
  /// **'Not delivered'**
  String get statusNotDelivered;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescription;

  /// No description provided for @receipientDetails.
  ///
  /// In en, this message translates to:
  /// **'Recipient Details'**
  String get receipientDetails;

  /// No description provided for @requestMessage.
  ///
  /// In en, this message translates to:
  /// **'You can mark not delivered after 3 days of requesting'**
  String get requestMessage;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @notDelivered.
  ///
  /// In en, this message translates to:
  /// **'Not delivered'**
  String get notDelivered;

  /// No description provided for @souqAlKahir.
  ///
  /// In en, this message translates to:
  /// **'Souq Alkhair'**
  String get souqAlKahir;

  /// No description provided for @addDonation.
  ///
  /// In en, this message translates to:
  /// **'Add Donation'**
  String get addDonation;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @noDonationsFound.
  ///
  /// In en, this message translates to:
  /// **'No donations found'**
  String get noDonationsFound;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionAmount;

  /// No description provided for @transactionTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get transactionTimestamp;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @walletTopUp.
  ///
  /// In en, this message translates to:
  /// **'Wallet Top Up'**
  String get walletTopUp;

  /// No description provided for @walletTopUpAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to top up'**
  String get walletTopUpAmountHint;

  /// No description provided for @walletTopUpSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get walletTopUpSubmit;

  /// No description provided for @walletTopUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet top up successful'**
  String get walletTopUpSuccess;

  /// No description provided for @walletTopUpError.
  ///
  /// In en, this message translates to:
  /// **'Wallet top up failed'**
  String get walletTopUpError;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @addFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get addFunds;

  /// No description provided for @addFundsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Funds added successfully'**
  String get addFundsSuccess;

  /// No description provided for @addFundsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add funds'**
  String get addFundsError;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @trackingMap.
  ///
  /// In en, this message translates to:
  /// **'Tracking Map'**
  String get trackingMap;

  /// No description provided for @trackingRoutes.
  ///
  /// In en, this message translates to:
  /// **'Tracking Routes'**
  String get trackingRoutes;

  /// No description provided for @trackingBalance.
  ///
  /// In en, this message translates to:
  /// **'Tracking Balance'**
  String get trackingBalance;

  /// No description provided for @trackingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Tracking Transactions'**
  String get trackingTransactions;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'phone number ex: 09XXXXXXXX'**
  String get phoneNumberHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
