import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// No description provided for @refreshStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatusTooltip;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @restartButton.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartButton;

  /// No description provided for @stopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// No description provided for @statusDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'ZeroTier Details'**
  String get statusDetailsTitle;

  /// No description provided for @nodeAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Node Address'**
  String get nodeAddressLabel;

  /// No description provided for @softwareVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Software Version'**
  String get softwareVersionLabel;

  /// No description provided for @onlineStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Online Status'**
  String get onlineStatusLabel;

  /// No description provided for @onlineStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatusOnline;

  /// No description provided for @onlineStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get onlineStatusOffline;

  /// No description provided for @primaryPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary Port'**
  String get primaryPortLabel;

  /// No description provided for @listeningAddressesLabel.
  ///
  /// In en, this message translates to:
  /// **'Listening Addresses:'**
  String get listeningAddressesLabel;

  /// No description provided for @noListeningAddresses.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noListeningAddresses;

  /// No description provided for @leaveNetworkConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Network?'**
  String get leaveNetworkConfirmationTitle;

  /// No description provided for @leaveNetworkConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave network {networkId}?'**
  String leaveNetworkConfirmationText(String networkId);

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @networkIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Network ID'**
  String get networkIdLabel;

  /// No description provided for @networkIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 16-character Network ID'**
  String get networkIdHint;

  /// No description provided for @invalidNetworkIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid Network ID'**
  String get invalidNetworkIdTitle;

  /// No description provided for @invalidNetworkIdText.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 16-character network ID.'**
  String get invalidNetworkIdText;

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinButton;

  /// No description provided for @networksTitle.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get networksTitle;

  /// No description provided for @refreshNetworksTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Network List'**
  String get refreshNetworksTooltip;

  /// No description provided for @noNetworksJoined.
  ///
  /// In en, this message translates to:
  /// **'No networks joined'**
  String get noNetworksJoined;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied {networkId} to clipboard!'**
  String copiedToClipboard(String networkId);

  /// No description provided for @copyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyTooltip;

  /// No description provided for @leaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveTooltip;

  /// No description provided for @clearInputTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear input'**
  String get clearInputTooltip;

  /// No description provided for @peersFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Peers feature coming soon'**
  String get peersFeatureComingSoon;

  /// No description provided for @noPeersFound.
  ///
  /// In en, this message translates to:
  /// **'No peers found'**
  String get noPeersFound;

  /// No description provided for @navBarLabelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get navBarLabelStatus;

  /// No description provided for @navBarLabelNetworks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get navBarLabelNetworks;

  /// No description provided for @navBarLabelPeers.
  ///
  /// In en, this message translates to:
  /// **'Peers'**
  String get navBarLabelPeers;

  /// No description provided for @appBarTitleStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get appBarTitleStatus;

  /// No description provided for @appBarTitleNetworks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get appBarTitleNetworks;

  /// No description provided for @appBarTitlePeers.
  ///
  /// In en, this message translates to:
  /// **'Peers'**
  String get appBarTitlePeers;

  /// No description provided for @joinNetworkSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined network {networkId}!'**
  String joinNetworkSuccessText(String networkId);

  /// No description provided for @joinNetworkErrorText.
  ///
  /// In en, this message translates to:
  /// **'Failed to join network: {error}'**
  String joinNetworkErrorText(String error);

  /// No description provided for @leaveNetworkSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Successfully left network {networkId}.'**
  String leaveNetworkSuccessText(String networkId);

  /// No description provided for @leaveNetworkErrorText.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave network: {error}'**
  String leaveNetworkErrorText(String error);

  /// No description provided for @refreshButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get refreshButtonLabel;

  /// No description provided for @loadPeersErrorText.
  ///
  /// In en, this message translates to:
  /// **'Failed to load peers: {error}'**
  String loadPeersErrorText(String error);

  /// No description provided for @loadNetworksErrorText.
  ///
  /// In en, this message translates to:
  /// **'Failed to load networks: {error}'**
  String loadNetworksErrorText(String error);

  /// No description provided for @serviceNotRunning.
  ///
  /// In en, this message translates to:
  /// **'ZeroTier service is not running'**
  String get serviceNotRunning;

  /// No description provided for @moduleNotRunning.
  ///
  /// In en, this message translates to:
  /// **'ZeroTier Magisk module is not running. Please check if you have installed the ZeroTier Magisk module.'**
  String get moduleNotRunning;

  /// No description provided for @peerTunneled.
  ///
  /// In en, this message translates to:
  /// **'Relayed'**
  String get peerTunneled;

  /// No description provided for @peerDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get peerDirect;

  /// No description provided for @networkConfigDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Network Configuration'**
  String get networkConfigDialogTitle;

  /// No description provided for @editNetworkConfigTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit configuration'**
  String get editNetworkConfigTooltip;

  /// No description provided for @networkConfigOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'ZeroTier service is not running. Changes will take effect the next time it starts.'**
  String get networkConfigOfflineNote;

  /// No description provided for @networkConfigWhitelistNote.
  ///
  /// In en, this message translates to:
  /// **'allowManaged contains an IP whitelist. Saving will replace it with a simple on/off setting.'**
  String get networkConfigWhitelistNote;

  /// No description provided for @allowManagedLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow Managed Addresses'**
  String get allowManagedLabel;

  /// No description provided for @allowManagedDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow ZeroTier to assign managed IP addresses and routes'**
  String get allowManagedDesc;

  /// No description provided for @allowGlobalLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow Global Addresses'**
  String get allowGlobalLabel;

  /// No description provided for @allowGlobalDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow ZeroTier to assign public (global) IP addresses and routes'**
  String get allowGlobalDesc;

  /// No description provided for @allowDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow Default Route'**
  String get allowDefaultLabel;

  /// No description provided for @allowDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this network as the system default route (full tunnel)'**
  String get allowDefaultDesc;

  /// No description provided for @allowDNSLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow DNS'**
  String get allowDNSLabel;

  /// No description provided for @allowDNSDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow ZeroTier to configure DNS servers'**
  String get allowDNSDesc;

  /// No description provided for @networkConfigAppliedText.
  ///
  /// In en, this message translates to:
  /// **'Configuration of network {networkId} applied.'**
  String networkConfigAppliedText(String networkId);

  /// No description provided for @networkConfigSavedOfflineText.
  ///
  /// In en, this message translates to:
  /// **'Configuration of network {networkId} saved. It will take effect when the service starts.'**
  String networkConfigSavedOfflineText(String networkId);

  /// No description provided for @networkConfigApplyErrorText.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply configuration: {error}'**
  String networkConfigApplyErrorText(String error);
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
