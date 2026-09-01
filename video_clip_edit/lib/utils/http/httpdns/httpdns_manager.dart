// HTTPDNS 管理器 - 独立功能模块
// 负责 HTTPDNS 的初始化、配置和管理，与阿里云文档流程一致
// 参考：https://help.aliyun.com/zh/document_detail/2881388.html
import 'package:aliyun_httpdns/aliyun_httpdns.dart';
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

/// HTTPDNS管理器
class HttpDnsManager {
  static bool _initialized = false;

  /// 初始化HTTPDNS
  /// [config] HTTPDNS配置信息
  static Future<bool> init(HttpDnsConfig config) async {
    if (_initialized) {
      byDebugPrint('HTTPDNS已经初始化，跳过重复初始化', tag: '[HTTPDNS] ');
      return true;
    }

    try {
      byDebugPrint('开始初始化HTTPDNS...', tag: '[HTTPDNS] ');

      // 第一阶段：初始化基本配置
      await AliyunHttpdns.init(
        accountId: config.accountId,
        secretKey: config.secretKey,
        aesSecretKey: config.aesSecretKey,
      );

      // 第二阶段：设置功能选项
      await AliyunHttpdns.setHttpsRequestEnabled(config.enableHttps);
      await AliyunHttpdns.setLogEnabled(config.enableLog);
      if (config.discardExpiredAfterSeconds != null) {
        await AliyunHttpdns.setPersistentCacheIPEnabled(
          config.enablePersistentCache,
          discardExpiredAfterSeconds: config.discardExpiredAfterSeconds!,
        );
      } else {
        await AliyunHttpdns.setPersistentCacheIPEnabled(
          config.enablePersistentCache,
        );
      }
      await AliyunHttpdns.setReuseExpiredIPEnabled(config.enableReuseExpiredIp);
      await AliyunHttpdns.setPreResolveAfterNetworkChanged(
        config.enablePreResolveAfterNetworkChanged,
      );

      if (config.ipRankingList != null && config.ipRankingList!.isNotEmpty) {
        await AliyunHttpdns.setIPRankingList(config.ipRankingList!);
      }

      // 第三阶段：构建服务（必须调用）
      await AliyunHttpdns.build();

      // 设置预解析域名
      if (config.preResolveHosts != null &&
          config.preResolveHosts!.isNotEmpty) {
        await AliyunHttpdns.setPreResolveHosts(
          config.preResolveHosts!,
          ipType: 'both',
        );
      } else {
        // 如果没有指定，从API前缀中提取域名进行预解析
        final apiPrefix = APIs.apiPrefix;
        final uri = Uri.tryParse(apiPrefix);
        if (uri != null && uri.host.isNotEmpty) {
          await AliyunHttpdns.setPreResolveHosts([uri.host], ipType: 'both');
          byDebugPrint('已设置预解析域名: ${uri.host}', tag: '[HTTPDNS] ');
        }
      }

      _initialized = true;
      byDebugPrint('HTTPDNS初始化成功', tag: '[HTTPDNS] ');
      return true;
    } catch (e) {
      byDebugPrint('HTTPDNS初始化失败: $e', tag: '[HTTPDNS] ');
      return false;
    }
  }

  /// 解析域名
  /// [hostname] 要解析的域名
  /// [ipType] IP类型：'auto', 'ipv4', 'ipv6', 'both'
  static Future<Map<String, List<String>>> resolveHost(
    String hostname, {
    String ipType = 'both',
  }) async {
    try {
      final res = await AliyunHttpdns.resolveHostSyncNonBlocking(
        hostname,
        ipType: ipType,
      );
      return res;
    } catch (e) {
      byDebugPrint('HTTPDNS解析失败: $e', tag: '[HTTPDNS] ');
      return {'ipv4': [], 'ipv6': []};
    }
  }

  /// 获取SessionId
  static Future<String?> getSessionId() async {
    try {
      return await AliyunHttpdns.getSessionId();
    } catch (e) {
      byDebugPrint('获取SessionId失败: $e', tag: '[HTTPDNS] ');
      return null;
    }
  }

  /// 清除所有缓存
  static Future<void> cleanCache() async {
    try {
      await AliyunHttpdns.cleanAllHostCache();
      byDebugPrint('HTTPDNS缓存清除成功', tag: '[HTTPDNS] ');
    } catch (e) {
      byDebugPrint('清除HTTPDNS缓存失败: $e', tag: '[HTTPDNS] ');
    }
  }

  /// 检查是否已初始化
  static bool get isInitialized => _initialized;
}
