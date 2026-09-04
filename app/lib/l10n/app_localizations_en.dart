// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get statusRunning => 'Running';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get refreshStatusTooltip => 'Refresh Status';

  @override
  String get startButton => 'Start';

  @override
  String get restartButton => 'Restart';

  @override
  String get stopButton => 'Stop';

  @override
  String get statusDetailsTitle => 'ZeroTier Details';

  @override
  String get nodeAddressLabel => 'Node Address';

  @override
  String get softwareVersionLabel => 'Software Version';

  @override
  String get onlineStatusLabel => 'Online Status';

  @override
  String get onlineStatusOnline => 'Online';

  @override
  String get onlineStatusOffline => 'Offline';

  @override
  String get primaryPortLabel => 'Primary Port';

  @override
  String get listeningAddressesLabel => 'Listening Addresses:';

  @override
  String get noListeningAddresses => 'None';

  @override
  String get leaveNetworkConfirmationTitle => 'Leave Network?';

  @override
  String leaveNetworkConfirmationText(String networkId) {
    return 'Are you sure you want to leave network $networkId?';
  }

  @override
  String get confirmButton => 'Confirm';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get networkIdLabel => 'Network ID';

  @override
  String get networkIdHint => 'Enter 16-character Network ID';

  @override
  String get invalidNetworkIdTitle => 'Invalid Network ID';

  @override
  String get invalidNetworkIdText => 'Please enter a 16-character network ID.';

  @override
  String get joinButton => 'Join';

  @override
  String get networksTitle => 'Networks';

  @override
  String get refreshNetworksTooltip => 'Refresh Network List';

  @override
  String get noNetworksJoined => 'No networks joined';

  @override
  String copiedToClipboard(String networkId) {
    return 'Copied $networkId to clipboard!';
  }

  @override
  String get copyTooltip => 'Copy';

  @override
  String get leaveTooltip => 'Leave';

  @override
  String get clearInputTooltip => 'Clear input';

  @override
  String get peersFeatureComingSoon => 'Peers feature coming soon';

  @override
  String get noPeersFound => 'No peers found';

  @override
  String get navBarLabelStatus => 'Status';

  @override
  String get navBarLabelNetworks => 'Networks';

  @override
  String get navBarLabelPeers => 'Peers';

  @override
  String get appBarTitleStatus => 'Status';

  @override
  String get appBarTitleNetworks => 'Networks';

  @override
  String get appBarTitlePeers => 'Peers';

  @override
  String joinNetworkSuccessText(String networkId) {
    return 'Successfully joined network $networkId!';
  }

  @override
  String joinNetworkErrorText(String error) {
    return 'Failed to join network: $error';
  }

  @override
  String leaveNetworkSuccessText(String networkId) {
    return 'Successfully left network $networkId.';
  }

  @override
  String leaveNetworkErrorText(String error) {
    return 'Failed to leave network: $error';
  }

  @override
  String get refreshButtonLabel => 'Retry';

  @override
  String loadPeersErrorText(String error) {
    return 'Failed to load peers: $error';
  }

  @override
  String loadNetworksErrorText(String error) {
    return 'Failed to load networks: $error';
  }

  @override
  String get serviceNotRunning => 'ZeroTier service is not running';

  @override
  String get moduleNotRunning =>
      'ZeroTier Magisk module is not running. Please check if you have installed the ZeroTier Magisk module.';

  @override
  String get peerTunneled => 'Relayed';

  @override
  String get peerDirect => 'Direct';

  @override
  String get networkConfigDialogTitle => 'Network Configuration';

  @override
  String get editNetworkConfigTooltip => 'Edit configuration';

  @override
  String get networkConfigOfflineNote =>
      'ZeroTier service is not running. Changes will take effect the next time it starts.';

  @override
  String get networkConfigWhitelistNote =>
      'allowManaged contains an IP whitelist. Saving will replace it with a simple on/off setting.';

  @override
  String get allowManagedLabel => 'Allow Managed Addresses';

  @override
  String get allowManagedDesc =>
      'Allow ZeroTier to assign managed IP addresses and routes';

  @override
  String get allowGlobalLabel => 'Allow Global Addresses';

  @override
  String get allowGlobalDesc =>
      'Allow ZeroTier to assign public (global) IP addresses and routes';

  @override
  String get allowDefaultLabel => 'Allow Default Route';

  @override
  String get allowDefaultDesc =>
      'Use this network as the system default route (full tunnel)';

  @override
  String get allowDNSLabel => 'Allow DNS';

  @override
  String get allowDNSDesc => 'Allow ZeroTier to configure DNS servers';

  @override
  String networkConfigAppliedText(String networkId) {
    return 'Configuration of network $networkId applied.';
  }

  @override
  String networkConfigSavedOfflineText(String networkId) {
    return 'Configuration of network $networkId saved. It will take effect when the service starts.';
  }

  @override
  String networkConfigApplyErrorText(String error) {
    return 'Failed to apply configuration: $error';
  }
}
