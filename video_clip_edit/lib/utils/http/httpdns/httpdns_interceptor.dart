// HTTPDNS拦截器 - 在请求时将域名替换为 HTTPDNS 解析的 IP（与适配器配合使用）
// 无阿里云 SDK 时使用 HttpDnsManager.resolveHost，返回空则不替换，走系统 DNS
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'httpdns_manager.dart';
import 'httpdns_adapter.dart';

/// HTTPDNS 拦截器
class HttpDnsInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!HttpDnsManager.isInitialized) {
      handler.next(options);
      return;
    }

    try {
      final uri = options.uri;
      final host = uri.host;

      if (host == 'localhost' ||
          host == '127.0.0.1' ||
          RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(host)) {
        handler.next(options);
        return;
      }

      var res = await HttpDnsManager.resolveHost(host, ipType: 'ipv4');
      var ipv4 = res['ipv4'] ?? [];

      if (ipv4.isNotEmpty) {
        final ip = ipv4.first;

        options.extra['httpdns_original_host'] = host;
        options.extra['httpdns_resolved_ip'] = ip;
        setIpDomainMapping(ip, host);

        final originalBaseUrl = options.baseUrl;
        if (originalBaseUrl.contains(host)) {
          options.baseUrl = originalBaseUrl.replaceAll(host, ip);
        }

        options.headers['Host'] = host;
      } else {
        debugPrint('[HTTPDNS拦截器] 无解析结果 $host，本请求走系统 DNS');
      }
    } catch (e) {
      debugPrint('[HTTPDNS拦截器] 解析失败: $e，本请求走系统 DNS');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}
