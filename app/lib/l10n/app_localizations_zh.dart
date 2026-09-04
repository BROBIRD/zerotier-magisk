// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get statusRunning => '运行中';

  @override
  String get statusStopped => '已停止';

  @override
  String get refreshStatusTooltip => '刷新状态';

  @override
  String get startButton => '启动';

  @override
  String get restartButton => '重启';

  @override
  String get stopButton => '停止';

  @override
  String get statusDetailsTitle => 'ZeroTier 详细信息';

  @override
  String get nodeAddressLabel => '节点地址';

  @override
  String get softwareVersionLabel => '软件版本';

  @override
  String get onlineStatusLabel => '在线状态';

  @override
  String get onlineStatusOnline => '在线';

  @override
  String get onlineStatusOffline => '离线';

  @override
  String get primaryPortLabel => '主端口';

  @override
  String get listeningAddressesLabel => '监听地址:';

  @override
  String get noListeningAddresses => '无';

  @override
  String get leaveNetworkConfirmationTitle => '离开网络?';

  @override
  String leaveNetworkConfirmationText(String networkId) {
    return '您确定要离开网络 $networkId 吗?';
  }

  @override
  String get confirmButton => '确认';

  @override
  String get cancelButton => '取消';

  @override
  String get networkIdLabel => '网络 ID';

  @override
  String get networkIdHint => '输入 16 位网络 ID';

  @override
  String get invalidNetworkIdTitle => '无效的网络 ID';

  @override
  String get invalidNetworkIdText => '请输入一个 16 位的网络 ID。';

  @override
  String get joinButton => '加入';

  @override
  String get networksTitle => '网络';

  @override
  String get refreshNetworksTooltip => '刷新网络列表';

  @override
  String get noNetworksJoined => '未加入任何网络';

  @override
  String copiedToClipboard(String networkId) {
    return '已将 $networkId 复制到剪贴板!';
  }

  @override
  String get copyTooltip => '复制';

  @override
  String get leaveTooltip => '离开';

  @override
  String get clearInputTooltip => '清除输入';

  @override
  String get peersFeatureComingSoon => '节点功能即将推出';

  @override
  String get noPeersFound => '未找到节点';

  @override
  String get navBarLabelStatus => '状态';

  @override
  String get navBarLabelNetworks => '网络';

  @override
  String get navBarLabelPeers => '节点';

  @override
  String get appBarTitleStatus => '状态';

  @override
  String get appBarTitleNetworks => '网络';

  @override
  String get appBarTitlePeers => '节点';

  @override
  String joinNetworkSuccessText(String networkId) {
    return '成功加入网络 $networkId!';
  }

  @override
  String joinNetworkErrorText(String error) {
    return '加入网络失败: $error';
  }

  @override
  String leaveNetworkSuccessText(String networkId) {
    return '成功离开网络 $networkId。';
  }

  @override
  String leaveNetworkErrorText(String error) {
    return '离开网络失败: $error';
  }

  @override
  String get refreshButtonLabel => '重试';

  @override
  String loadPeersErrorText(String error) {
    return '加载节点列表失败: $error';
  }

  @override
  String loadNetworksErrorText(String error) {
    return '加载网络列表失败: $error';
  }

  @override
  String get serviceNotRunning => 'ZeroTier服务未运行';

  @override
  String get moduleNotRunning =>
      'ZeroTier Magisk模块未运行，请检查您是否安装Zerotier Magisk模块。';

  @override
  String get peerTunneled => '中继';

  @override
  String get peerDirect => '直连';

  @override
  String get networkConfigDialogTitle => '网络配置';

  @override
  String get editNetworkConfigTooltip => '编辑配置';

  @override
  String get networkConfigOfflineNote => 'ZeroTier 服务未运行，配置将在下次启动时生效。';

  @override
  String get networkConfigWhitelistNote =>
      'allowManaged 当前包含 IP 白名单，保存后将改为简单的开/关设置。';

  @override
  String get allowManagedLabel => '允许托管地址';

  @override
  String get allowManagedDesc => '允许 ZeroTier 配置托管的 IP 地址与路由';

  @override
  String get allowGlobalLabel => '允许全局地址';

  @override
  String get allowGlobalDesc => '允许 ZeroTier 分配公网（全局）范围的 IP 与路由';

  @override
  String get allowDefaultLabel => '允许默认路由';

  @override
  String get allowDefaultDesc => '允许 ZeroTier 接管系统默认路由（全隧道）';

  @override
  String get allowDNSLabel => '允许 DNS';

  @override
  String get allowDNSDesc => '允许 ZeroTier 设置 DNS 服务器';

  @override
  String networkConfigAppliedText(String networkId) {
    return '网络 $networkId 的配置已生效。';
  }

  @override
  String networkConfigSavedOfflineText(String networkId) {
    return '网络 $networkId 的配置已保存，将在服务启动后生效。';
  }

  @override
  String networkConfigApplyErrorText(String error) {
    return '应用配置失败: $error';
  }
}
