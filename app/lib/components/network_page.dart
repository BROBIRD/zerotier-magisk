import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import '../services/zerotier_service.dart';
import '../l10n/app_localizations.dart';

class NetworkPage extends StatefulWidget {
  final ZerotierService zerotierService;

  const NetworkPage({
    super.key,
    required this.zerotierService,
  }); 

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final _idInputController = TextEditingController();
  bool _isLoading = false;
  List<String> _networks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _idInputController.addListener(_onTextChanged);
    _fetchNetworkList();
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _setLoading(bool loading) {
    if (!mounted) return;
    setState(() {
      _isLoading = loading;
      if (loading && _error != null) {
         _error = null;
      }
    });
  }

  Future<void> _fetchNetworkList() async {
    _setLoading(true);
    try {
      final networks = await widget.zerotierService.loadNetwork();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          if (networks == null) {
            // ZeroTier服务不可用
            _error = l10n.serviceNotRunning;
            _networks = [];
          } else {
            _networks = List.from(networks);
            _error = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // 存储原始错误信息
        final rawError = e.toString();
        setState(() {
          _error = rawError; // 存储原始错误
          _networks = [];
        });
        
        // 在界面上显示本地化错误信息
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loadNetworksErrorText(rawError)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
       _setLoading(false);
    }
  }

  Future<void> _performJoinNetwork(String networkId) async {
    if (_isLoading) return;
    _setLoading(true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await widget.zerotierService.joinNetwork(networkId);
      if (mounted) {
        if (!widget.zerotierService.runningStatus) {
          // ZeroTier服务未运行
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.serviceNotRunning),
              backgroundColor: Colors.red,
            ),
          );
        } else if (result) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: l10n.joinNetworkSuccessText(networkId),
          );
          _idInputController.clear();
        } else {
          // 其他失败
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.joinNetworkErrorText("Unknown error")),
              backgroundColor: Colors.red,
            ),
          );
        }
        await _fetchNetworkList();
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.joinNetworkErrorText(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _performLeaveNetwork(String networkId) async {
    if (_isLoading) return;
    _setLoading(true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await widget.zerotierService.leaveNetwork(networkId);
      if (mounted) {
        if (!widget.zerotierService.runningStatus) {
          // ZeroTier服务未运行
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.serviceNotRunning),
              backgroundColor: Colors.red,
            ),
          );
        } else if (result) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: l10n.leaveNetworkSuccessText(networkId),
          );
        } else {
          // 其他失败
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.leaveNetworkErrorText("Unknown error")),
              backgroundColor: Colors.red,
            ),
          );
        }
        await _fetchNetworkList();
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.leaveNetworkErrorText(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  void _showLeaveConfirmation(String networkId) {
     final l10n = AppLocalizations.of(context)!;
     QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: l10n.leaveNetworkConfirmationTitle,
        text: l10n.leaveNetworkConfirmationText(networkId),
        confirmBtnText: l10n.confirmButton,
        cancelBtnText: l10n.cancelButton,
        confirmBtnColor: Colors.red,
        onConfirmBtnTap: () {
          Navigator.pop(context);
          _performLeaveNetwork(networkId);
        },
        onCancelBtnTap: () => Navigator.pop(context),
      );
  }

  Future<void> _showNetworkConfigEditor(String networkId) async {
    final result = await showDialog<NetworkLocalConfig>(
      context: context,
      builder: (dialogContext) => _NetworkConfigDialog(
        zerotierService: widget.zerotierService,
        networkId: networkId,
      ),
    );

    // result 为 null 表示用户取消
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final applyResult = await widget.zerotierService.applyNetworkConfig(networkId, result);
    if (!mounted) return;

    if (applyResult == NetworkConfigApplyResult.online) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: l10n.networkConfigAppliedText(networkId),
      );
    } else if (applyResult == NetworkConfigApplyResult.offline) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: l10n.networkConfigSavedOfflineText(networkId),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.networkConfigApplyErrorText(l10n.moduleNotRunning)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _idInputController.removeListener(_onTextChanged);
    _idInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final l10n = AppLocalizations.of(context)!;
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Expanded(
                  child: TextField(
                      controller: _idInputController,
                      textAlign: TextAlign.center,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]'))
                      ],
                      enabled: !_isLoading,
                      maxLength: 16,
                      decoration: InputDecoration(
                          labelText: l10n.networkIdLabel,
                          hintText: l10n.networkIdHint,
                          prefixIcon: const Icon(Icons.lan_outlined),
                          suffixIcon: _idInputController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: !_isLoading ? () => _idInputController.clear() : null,
                                  tooltip: l10n.clearInputTooltip,
                                )
                              : null,
                          counterText: "",
                          border: const OutlineInputBorder()
                      )
                  )
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: _isLoading || _idInputController.text.isEmpty
                      ? null
                      : () {
                          final networkId = _idInputController.text;
                          if (networkId.length != 16) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.warning,
                                title: l10n.invalidNetworkIdTitle,
                                text: l10n.invalidNetworkIdText,
                              );
                              return;
                            }
                            _performJoinNetwork(networkId);
                       },
                  label: Text(l10n.joinButton),
                  icon: const Icon(Icons.add_link)),
            ]),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
                title: Text(l10n.networksTitle, style: Theme.of(context).textTheme.titleMedium),
                trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.refreshNetworksTooltip,
                    onPressed: _isLoading ? null : _fetchNetworkList
                )
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading && _networks.isEmpty
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.loadNetworksErrorText(_error!),
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                   icon: const Icon(Icons.refresh),
                                   label: Text(l10n.refreshButtonLabel ?? 'Retry'),
                                   onPressed: _isLoading ? null : _fetchNetworkList,
                                )
                              ],
                            ),
                          )
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchNetworkList,
                          child: _networks.isEmpty
                              ? LayoutBuilder(
                                 builder: (context, constraints) => SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: Container(
                                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          l10n.noNetworksJoined,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).disabledColor
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _networks.length,
                                  itemBuilder: (BuildContext ctx, int i) {
                                    final networkId = _networks[i];
                                    return Card(
                                        elevation: 1.5,
                                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                                        child: ListTile(
                                            leading: CircleAvatar(
                                              child: Icon(Icons.vpn_key, size: 18, color: Theme.of(context).colorScheme.secondary),
                                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                            ),
                                            title: Text(networkId, style: const TextStyle(fontFamily: 'monospace', letterSpacing: 0.8)),
                                            onTap: _isLoading ? null : () => _showNetworkConfigEditor(networkId),
                                            trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                      onPressed: _isLoading ? null : () => _showNetworkConfigEditor(networkId),
                                                      tooltip: l10n.editNetworkConfigTooltip,
                                                      icon: const Icon(Icons.tune, size: 20)
                                                  ),
                                                  IconButton(
                                                      onPressed: _isLoading ? null : () {
                                                        Clipboard.setData(ClipboardData(text: networkId));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text(l10n.copiedToClipboard(networkId)))
                                                        );
                                                      },
                                                      tooltip: l10n.copyTooltip,
                                                      icon: const Icon(Icons.copy, size: 20)
                                                  ),
                                                  IconButton(
                                                      onPressed: _isLoading ? null : () => _showLeaveConfirmation(networkId),
                                                      tooltip: l10n.leaveTooltip,
                                                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 20)
                                                  ),
                                                ])
                                        )
                                    );
                                  }
                              ),
                          )
            ),
          ],
        ));
  }
}

/// 网络配置编辑对话框，修改 `<network-id>`.local.conf 中的开关项
class _NetworkConfigDialog extends StatefulWidget {
  final ZerotierService zerotierService;
  final String networkId;

  const _NetworkConfigDialog({
    required this.zerotierService,
    required this.networkId,
  });

  @override
  State<_NetworkConfigDialog> createState() => _NetworkConfigDialogState();
}

class _NetworkConfigDialogState extends State<_NetworkConfigDialog> {
  NetworkLocalConfig? _config;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await widget.zerotierService.loadNetworkConfig(widget.networkId);
    if (mounted) {
      setState(() {
        _config = config;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = _config;

    return AlertDialog(
      title: Text(l10n.networkConfigDialogTitle),
      content: config == null
          ? const SizedBox(
              height: 160,
              width: double.maxFinite,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.networkId,
                    style: const TextStyle(fontFamily: 'monospace', letterSpacing: 0.8),
                  ),
                  if (!widget.zerotierService.runningStatus) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.networkConfigOfflineNote,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  if (config.managedWhitelist != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.networkConfigWhitelistNote,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.allowManagedLabel),
                    subtitle: Text(l10n.allowManagedDesc),
                    value: config.allowManaged,
                    onChanged: (value) => setState(() => config.allowManaged = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.allowGlobalLabel),
                    subtitle: Text(l10n.allowGlobalDesc),
                    value: config.allowGlobal,
                    onChanged: (value) => setState(() => config.allowGlobal = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.allowDefaultLabel),
                    subtitle: Text(l10n.allowDefaultDesc),
                    value: config.allowDefault,
                    onChanged: (value) => setState(() => config.allowDefault = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.allowDNSLabel),
                    subtitle: Text(l10n.allowDNSDesc),
                    value: config.allowDNS,
                    onChanged: (value) => setState(() => config.allowDNS = value),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: config == null ? null : () => Navigator.pop(context, config),
          child: Text(l10n.confirmButton),
        ),
      ],
    );
  }
} 