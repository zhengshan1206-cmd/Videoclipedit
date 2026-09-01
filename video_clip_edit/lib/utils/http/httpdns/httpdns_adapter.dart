// HTTPDNS适配器实现
// 参考阿里云文档：https://help.aliyun.com/zh/document_detail/2881388.html
// 通过自定义 connectionFactory 实现：拦截请求 → HTTPDNS 解析 → 用 IP 建连 → HTTPS 时 SNI 使用原始域名
import 'dart:io';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:aliyun_httpdns/aliyun_httpdns.dart';

// 全局映射：IP地址 -> 原始域名（用于 SNI，拦截器修改 baseUrl 时写入）
final Map<String, String> _ipToDomainMap = {};

/// 设置 IP->域名映射（供拦截器调用，用于 SNI）
void setIpDomainMapping(String ip, String domain) {
  _ipToDomainMap[ip] = domain;
}

/// 清除 IP->域名映射
void clearIpDomainMapping() {
  _ipToDomainMap.clear();
}

/// 构建支持 HTTPDNS 的 Dio 适配器
/// 文档推荐方式：connectionFactory 内解析域名 → 用 IP 建 TCP → HTTPS 时 SecureSocket.secure(raw, host: 域名)
IOHttpClientAdapter buildHttpdnsHttpClientAdapter() {
  final IOHttpClientAdapter adapter = IOHttpClientAdapter(
    createHttpClient: () {
      final HttpClient client = HttpClient();
      _configureHttpClient(client);
      _configureConnectionFactory(client);
      return client;
    },
  )..validateCertificate = (cert, host, port) => true;

  return adapter;
}

/// HttpClient 基础配置（与文档一致）
void _configureHttpClient(HttpClient client) {
  client.findProxy = (Uri _) => 'DIRECT';
  client.idleTimeout = const Duration(seconds: 90);
  client.maxConnectionsPerHost = 8;
  client.badCertificateCallback = (cert, host, port) => true;
}

/// 配置基于 HTTPDNS 的连接工厂
///
/// 结论：**实际 TCP/TLS 建连始终使用 IP**（当 HTTPDNS 有结果时）；**SNI 与 HTTP Host 头使用原始域名**。
/// - 若 [uri.host] 已是 IP（拦截器改过 baseUrl）：直接用该 IP 建连，SNI 从 _ipToDomainMap 取原始域名。
/// - 若 [uri.host] 是域名：先 _resolveTargets 解析，有 IP 则连 IP、SNI=域名；无 IP 则回退系统 DNS（连域名）。
/// 文档：先 TCP 连 IP，再 TLS（SNI=域名），并支持取消
void _configureConnectionFactory(HttpClient client) {
  client.connectionFactory =
      (Uri uri, String? proxyHost, int? proxyPort) async {
        final String domain = uri.host;
        final bool https = uri.scheme.toLowerCase() == 'https';
        final int port = uri.port == 0 ? (https ? 443 : 80) : uri.port;

        // 若 host 已是 IP（拦截器已改过 baseUrl），从映射取原始域名用于 SNI
        String? originalDomain;
        final isIpAddress = RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(domain);
        if (isIpAddress) {
          originalDomain = _ipToDomainMap[domain];
        }

        // 解析目标：域名则走 HTTPDNS，已是 IP 则直接用
        List<InternetAddress> targets = [];
        Object target = domain;

        if (!isIpAddress) {
          targets = await _resolveTargets(domain);
          target = targets.isNotEmpty ? targets.first : domain;
        } else {
          target = InternetAddress.tryParse(domain) ?? domain;
          if (target is InternetAddress) {
            targets = [target];
          }
        }

        if (!https) {
          return Socket.startConnect(target, port);
        }

        // HTTPS：先 TCP 连 IP，再 TLS（SNI=原始域名），并保持可取消（与文档一致）
        bool cancelled = false;
        final Future<ConnectionTask<Socket>> rawStart = Socket.startConnect(
          target,
          port,
        );
        final sniDomain = originalDomain ?? domain;

        final Future<Socket> upgraded = rawStart.then((
          ConnectionTask<Socket> task,
        ) async {
          final Socket raw = await task.socket;
          if (cancelled) {
            raw.destroy();
            throw const SocketException('Connection cancelled');
          }
          final SecureSocket secure = await SecureSocket.secure(
            raw,
            host: sniDomain,
          );
          if (cancelled) {
            secure.destroy();
            throw const SocketException('Connection cancelled');
          }
          return secure;
        });

        return ConnectionTask.fromSocket(upgraded, () {
          cancelled = true;
          rawStart.then((ConnectionTask<Socket> t) => t.cancel());
        });
      };
}

/// 通过 HTTPDNS 解析目标 IP 列表（与文档 _resolveTargets 一致）
Future<List<InternetAddress>> _resolveTargets(String domain) async {
  try {
    final res = await AliyunHttpdns.resolveHostSyncNonBlocking(
      domain,
      ipType: 'both',
    );
    final List<String> ipv4 = res['ipv4'] ?? [];
    final List<String> ipv6 = res['ipv6'] ?? [];
    final List<InternetAddress> targets = [
      ...ipv4.map(InternetAddress.tryParse).whereType<InternetAddress>(),
      ...ipv6.map(InternetAddress.tryParse).whereType<InternetAddress>(),
    ];
    if (targets.isEmpty) {
      debugPrint('[HTTPDNS适配器] 无解析结果 $domain，回退系统 DNS');
    } else {
      debugPrint('[HTTPDNS适配器] 解析 $domain -> ${targets.first.address}');
    }
    return targets;
  } catch (e) {
    debugPrint('[HTTPDNS适配器] 解析失败: $e，回退系统 DNS');
    return const <InternetAddress>[];
  }
}
