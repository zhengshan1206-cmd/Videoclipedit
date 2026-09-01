// HTTPDNS 管理器 - 独立功能模块
// 鸿蒙等平台无 aliyun_httpdns 时使用无操作实现，直接走系统 DNS
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';

/// HTTPDNS 配置（与文档 5.2 初始化参数、5.8 持久化缓存、5.9 IP 优选一致）
class HttpDnsConfig {
  /// 必选，Account ID
  final int accountId;

  /// 可选，加签密钥
  final String secretKey;

  /// 可选，加密密钥（内容加密会增加计费）
  final String? aesSecretKey;

  /// 是否使用 HTTPS 解析链路（true 会增加计费）
  final bool enableHttps;

  /// 是否开启日志
  final bool enableLog;

  /// 是否开启持久化缓存
  final bool enablePersistentCache;

  /// 持久化缓存时，过期超过此秒数的记录在 App 启动时丢弃（可选，文档 5.8）
  final int? discardExpiredAfterSeconds;

  /// 是否允许复用过期 IP
  final bool enableReuseExpiredIp;

  /// 网络切换时是否自动刷新预解析
  final bool enablePreResolveAfterNetworkChanged;

  /// IP 优选域名列表，如 {'www.aliyun.com': 443}（文档 5.9）
  final Map<String, int>? ipRankingList;

  /// 预解析域名列表（文档 5.4）
  final List<String>? preResolveHosts;

  const HttpDnsConfig({
    required this.accountId,
    required this.secretKey,
    this.aesSecretKey,
    this.enableHttps = true,
    this.enableLog = true,
    this.enablePersistentCache = true,
    this.discardExpiredAfterSeconds,
    this.enableReuseExpiredIp = true,
    this.enablePreResolveAfterNetworkChanged = true,
    this.ipRankingList,
    this.preResolveHosts,
  });
}

/// HTTPDNS管理器（无阿里云 SDK 时为 no-op，直接走系统 DNS）
class HttpDnsManager {
  static bool _initialized = false;

  /// 初始化HTTPDNS（当前为 no-op，仅标记已初始化）
  static Future<bool> init(HttpDnsConfig config) async {
    if (_initialized) {
      byDebugPrint('HTTPDNS已跳过（无阿里云SDK）', tag: '[HTTPDNS] ');
      return true;
    }
    _initialized = true;
    byDebugPrint('HTTPDNS使用系统DNS（鸿蒙等平台）', tag: '[HTTPDNS] ');
    return true;
  }

  /// 解析域名（no-op，返回空，拦截器将不替换 host）
  static Future<Map<String, List<String>>> resolveHost(
    String hostname, {
    String ipType = 'both',
  }) async {
    return {'ipv4': [], 'ipv6': []};
  }

  /// 获取SessionId
  static Future<String?> getSessionId() async {
    return null;
  }

  /// 清除所有缓存
  static Future<void> cleanCache() async {}

  /// 检查是否已初始化
  static bool get isInitialized => _initialized;
}
