import 'dart:io';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../models/peer_info.dart';

/// ZeroTier服务状态详情
class ZerotierStatus {
  final String address;
  final String version;
  final bool online;
  final int primaryPort;
  final List<String> listeningOn;

  ZerotierStatus({ 
    required this.address,
    required this.version,
    required this.online,
    required this.primaryPort,
    required this.listeningOn,
  });
  
  /// 从JSON创建状态对象
  factory ZerotierStatus.fromJson(Map<String, dynamic> json) {
    // 提取监听地址列表
    List<String> listeningAddresses = [];
    if (json['config'] != null && 
        json['config']['settings'] != null && 
        json['config']['settings']['listeningOn'] != null) {
      listeningAddresses = List<String>.from(json['config']['settings']['listeningOn']);
    }
    
    // 提取主端口
    int port = 0;
    if (json['config'] != null && 
        json['config']['settings'] != null && 
        json['config']['settings']['primaryPort'] != null) {
      port = json['config']['settings']['primaryPort'];
    }
    
    return ZerotierStatus(
      address: json['address'] ?? '',
      version: json['version'] ?? '',
      online: json['online'] ?? false,
      primaryPort: port,
      listeningOn: listeningAddresses,
    );
  }
}

/// 网络本地配置应用方式
enum NetworkConfigApplyResult {
  /// 已通过本地API应用，立即生效
  online,
  /// 已写入local.conf，服务下次启动时生效
  offline,
  /// 应用失败
  failure,
}

/// 网络本地配置，对应设备上的 `<network-id>`.local.conf
///
/// 文件为ZeroTier字典格式，每行一条 key=value
class NetworkLocalConfig {
  bool allowManaged;
  bool allowGlobal;
  bool allowDefault;
  bool allowDNS;

  /// allowManaged为IP白名单列表时的原始值，仅用于界面提示
  String? managedWhitelist;

  NetworkLocalConfig({
    this.allowManaged = true,
    this.allowGlobal = false,
    this.allowDefault = false,
    this.allowDNS = false,
    this.managedWhitelist,
  });

  /// ZeroTier内置默认值
  factory NetworkLocalConfig.defaults() => NetworkLocalConfig();

  /// 从local.conf文本内容解析
  factory NetworkLocalConfig.fromConf(String content) {
    final config = NetworkLocalConfig.defaults();
    for (final line in content.split('\n')) {
      final text = line.trim();
      if (text.isEmpty) continue;
      final eq = text.indexOf('=');
      if (eq <= 0) continue;
      final key = text.substring(0, eq).trim();
      final value = text.substring(eq + 1).trim();
      final lower = value.toLowerCase();
      final enabled = lower == '1' || lower == 'true' || lower == 't';
      switch (key) {
        case 'allowManaged':
          // ZeroTier将超过5个字符的值视为IP白名单列表
          if (value.length > 5) {
            config.managedWhitelist = value;
            config.allowManaged = true;
          } else {
            config.allowManaged = enabled;
          }
        case 'allowGlobal':
          config.allowGlobal = enabled;
        case 'allowDefault':
          config.allowDefault = enabled;
        case 'allowDNS':
          config.allowDNS = enabled;
      }
    }
    return config;
  }

  /// 生成local.conf文本内容
  String toConf() {
    final buffer = StringBuffer();
    buffer.write('allowManaged=${allowManaged ? '1' : '0'}\n');
    buffer.write('allowGlobal=${allowGlobal ? '1' : '0'}\n');
    buffer.write('allowDefault=${allowDefault ? '1' : '0'}\n');
    buffer.write('allowDNS=${allowDNS ? '1' : '0'}\n');
    return buffer.toString();
  }
}

/// ZeroTier服务，提供所有ZeroTier相关功能
class ZerotierService {  
  final AuthService _authService = AuthService();
  
  // 内部成员变量，存储最后一次加载的数据
  List<String> _networkList = [];
  List<PeerInfo> _peersList = [];
  ZerotierStatus? _statusInfo;
  
  // 表示ZeroTier服务是否正在运行
  bool runningStatus = false;
  
  // 允许外部访问最新数据的getter方法
  List<String> get networkList => _networkList;
  List<PeerInfo> get peersList => _peersList;
  ZerotierStatus? get statusInfo => _statusInfo;

  /// 向ZeroTier服务发送命令
  Future<bool> zerotierCommand(String command) async {
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      final file = File('$path/run/pipe');
      
      if (!await file.exists()) {
        developer.log('未找到ZeroTier命令管道: ${file.path}');
        runningStatus = false;
        // 特定错误，表示Magisk模块未运行
        throw const FileSystemException('MODULE_NOT_RUNNING');
      }
      
      await file.writeAsString(command);
      developer.log('已发送ZeroTier命令: $command');
      return true;
    } on FileSystemException catch (e) {
      if (e.message == 'MODULE_NOT_RUNNING') {
        developer.log('ZeroTier Magisk模块未运行');
      } else {
        developer.log('未找到ZeroTier命令管道，服务可能未运行');
      }
      runningStatus = false;
      return false;
    } catch (e) {
      developer.log('发送ZeroTier命令失败', error: e.toString());
      return false;
    }
  }

  /// 加载网络列表
  Future<List<String>?> loadNetwork() async {
    developer.log('开始加载网络列表');
    try {
      final client = await _authService.client;
      // 使用相对路径，基础URL已在客户端中配置
      final resp = await client.get('/network');
      
      if (resp.statusCode != 200) {
        throw HttpException('加载网络列表失败: ${resp.statusCode}');
      }
      
      final body = resp.data;
      _networkList = List<String>.from(body.map((u) => u['id']));
      developer.log('成功加载网络列表: ${_networkList.length} 个网络');
      return _networkList;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        developer.log('无法连接到ZeroTier服务：服务可能未运行');
      } else {
        developer.log('加载网络列表失败', error: e.toString());
      }
      _networkList = [];
      return null;
    } on SocketException {
      developer.log('无法连接到ZeroTier服务：服务可能未运行');
      _networkList = [];
      return null;
    } catch (e) {
      developer.log('加载网络列表失败', error: e.toString());
      _networkList = [];
      return null;
    }
  }

  /// 离开指定网络
  Future<bool> leaveNetwork(String id) async {
    try {
      final client = await _authService.client;
      // 使用相对路径
      final resp = await client.delete('/network/$id');
      final success = resp.statusCode == 200;
      
      if (success) {
        developer.log('成功离开网络: $id');
      } else {
        developer.log('离开网络失败: $id, 状态码: ${resp.statusCode}');
      }
      
      return success;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        developer.log('无法连接到ZeroTier服务：服务可能未运行');
        // 更新运行状态
        runningStatus = false;
      } else {
        developer.log('离开网络错误', error: e.toString());
      }
      return false;
    } on SocketException {
      developer.log('无法连接到ZeroTier服务：服务可能未运行');
      // 更新运行状态
      runningStatus = false;
      return false;
    } catch (e) {
      developer.log('离开网络错误', error: e.toString());
      return false;
    }
  }

  /// 加入指定网络
  Future<bool> joinNetwork(String id) async {
    try {
      if (id.isEmpty) {
        developer.log('无法加入空网络ID');
        return false;
      }
      
      final client = await _authService.client;
      // 使用相对路径
      final resp = await client.put('/network/$id');
      final success = resp.statusCode == 200;
      
      if (success) {
        developer.log('成功加入网络: $id');
      } else {
        developer.log('加入网络失败: $id, 状态码: ${resp.statusCode}');
      }
      
      return success;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        developer.log('无法连接到ZeroTier服务：服务可能未运行');
        // 更新运行状态
        runningStatus = false;
      } else {
        developer.log('加入网络错误', error: e.toString());
      }
      return false;
    } on SocketException {
      developer.log('无法连接到ZeroTier服务：服务可能未运行');
      // 更新运行状态
      runningStatus = false;
      return false;
    } catch (e) {
      developer.log('加入网络错误', error: e.toString());
      return false;
    }
  }

  /// 读取指定网络的本地配置
  ///
  /// 优先级: 设备上的 `<network-id>`.local.conf 文件 > 运行时API > 内置默认值
  Future<NetworkLocalConfig> loadNetworkConfig(String id) async {
    final fromFile = await _readNetworkLocalConf(id);
    if (fromFile != null) {
      return fromFile;
    }

    // 文件不可用时回退到运行时设置
    try {
      final client = await _authService.client;
      final resp = await client.get('/network/$id');
      if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
        final data = resp.data as Map<String, dynamic>;
        developer.log('已读取网络运行时配置: $id');
        return NetworkLocalConfig(
          allowManaged: data['allowManaged'] ?? true,
          allowGlobal: data['allowGlobal'] ?? false,
          allowDefault: data['allowDefault'] ?? false,
          allowDNS: data['allowDNS'] ?? false,
        );
      }
    } catch (e) {
      developer.log('读取网络运行时配置失败: $id', error: e.toString());
    }

    return NetworkLocalConfig.defaults();
  }

  /// 通过Magisk模块读取设备上的 `<network-id>`.local.conf
  Future<NetworkLocalConfig?> _readNetworkLocalConf(String id) async {
    try {
      final base = (await getApplicationDocumentsDirectory()).path;
      final netconfDir = Directory('$base/run/netconf');
      final current = File('${netconfDir.path}/$id.current');

      // 清除旧响应，避免读到上一次的内容
      if (await current.exists()) {
        await current.delete();
      }

      if (!await zerotierCommand('netconf read $id')) {
        return null;
      }

      // 等待模块（root）导出配置文件
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (await current.exists()) {
          final content = await current.readAsString();
          // 空文件表示设备上尚无该网络的local.conf
          if (content.trim().isEmpty) {
            return null;
          }
          return NetworkLocalConfig.fromConf(content);
        }
      }
      developer.log('等待导出local.conf超时: $id');
      return null;
    } catch (e) {
      developer.log('读取local.conf失败: $id', error: e.toString());
      return null;
    }
  }

  /// 保存网络本地配置
  ///
  /// 服务运行时通过本地API立即生效，由zerotier-one自动持久化到local.conf；
  /// 服务未运行时写入待装文件，由Magisk模块安装，下次启动生效
  Future<NetworkConfigApplyResult> applyNetworkConfig(String id, NetworkLocalConfig config) async {
    // 优先走本地API：立即生效且由服务自己持久化
    try {
      final client = await _authService.client;
      final resp = await client.post('/network/$id', data: {
        'allowManaged': config.allowManaged,
        'allowGlobal': config.allowGlobal,
        'allowDefault': config.allowDefault,
        'allowDNS': config.allowDNS,
      });
      if (resp.statusCode == 200) {
        runningStatus = true;
        developer.log('网络配置已通过API应用: $id');
        return NetworkConfigApplyResult.online;
      }
      developer.log('通过API应用网络配置失败: $id, 状态码: ${resp.statusCode}');
    } catch (e) {
      developer.log('通过API应用网络配置失败，回退到文件写入: $id', error: e.toString());
    }

    // 服务未运行：写入待装文件，通过模块管道安装
    try {
      final base = (await getApplicationDocumentsDirectory()).path;
      final netconfDir = Directory('$base/run/netconf');
      await netconfDir.create(recursive: true);
      await File('${netconfDir.path}/$id.pending').writeAsString(config.toConf());

      if (await zerotierCommand('netconf write $id')) {
        developer.log('网络配置已写入local.conf: $id');
        return NetworkConfigApplyResult.offline;
      }
      developer.log('发送netconf write命令失败: $id');
      return NetworkConfigApplyResult.failure;
    } catch (e) {
      developer.log('写入网络配置失败: $id', error: e.toString());
      return NetworkConfigApplyResult.failure;
    }
  }

  /// 加载 Peer 列表
  Future<List<PeerInfo>?> loadPeers() async {
    developer.log('开始加载 Peer 列表');
    try {
      final client = await _authService.client;
      final resp = await client.get('/peer');

      if (resp.statusCode != 200) {
        throw HttpException('加载 Peer 列表失败: ${resp.statusCode}');
      }

      final List<dynamic> rawPeers = resp.data;
      _peersList = rawPeers
          .map((p) => PeerInfo.fromJson(p as Map<String, dynamic>))
          .toList();

      // Sort the list (PLANETs first, then LEAFs by address)
      _peersList.sort();

      developer.log('成功加载 Peer 列表: ${_peersList.length} 个 Peers');
      return _peersList;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        developer.log('无法连接到ZeroTier服务：服务可能未运行');
      } else {
        developer.log('加载 Peer 列表 Dio 错误', error: e.toString(), stackTrace: e.stackTrace);
      }
      _peersList = [];
      return null;
    } on SocketException {
      developer.log('无法连接到ZeroTier服务：服务可能未运行');
      _peersList = [];
      return null;
    } catch (e, s) {
      developer.log('加载 Peer 列表失败', error: e.toString(), stackTrace: s);
      _peersList = [];
      return null;
    }
  }

  /// 加载ZeroTier服务状态
  Future<ZerotierStatus?> loadStatus() async {
    developer.log('检查ZeroTier服务状态');
    Map<String, dynamic>? statusData;

    try {
      // 尝试获取状态信息
      final client = await _authService.client;
      final response = await client.get('/status');
      
      if (response.statusCode == 200) {
        statusData = response.data;
        developer.log('已获取ZeroTier状态信息');
      } else {
        developer.log('获取ZeroTier状态信息失败: ${response.statusCode}');
        statusData = null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        developer.log('无法连接到ZeroTier服务：服务可能未运行');
      } else {
        developer.log('获取ZeroTier状态信息错误', error: e.toString());
      }
      statusData = null;
    } on SocketException {
      developer.log('无法连接到ZeroTier服务：服务可能未运行');
      statusData = null;
    } catch (e) {
      developer.log('检查ZeroTier状态错误', error: e.toString());
      statusData = null;
    }

    // 根据获取的状态信息更新运行状态和详情
    if (statusData != null) {
      runningStatus = true;
      _statusInfo = ZerotierStatus.fromJson(statusData);
      developer.log('ZeroTier服务状态: 运行中');
      developer.log('已加载ZeroTier详细状态信息');
      return _statusInfo;
    } else {
      runningStatus = false;
      _statusInfo = null;
      developer.log('ZeroTier服务状态: 未运行');
      return null;
    }
  }

  /// 释放资源
  void dispose() {
    _authService.dispose();
  }
} 