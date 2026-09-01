// HTTPDNS拦截器 - 在请求时将域名替换为 HTTPDNS 解析的 IP（与适配器配合使用）
// 参考：https://help.aliyun.com/zh/document_detail/2881388.html
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aliyun_httpdns/aliyun_httpdns.dart';
import 'httpdns_manager.dart';
import 'httpdns_adapter.dart';

/// HTTPDNS 拦截器
///
/// 作用：解析域名 → 将 [options.baseUrl] 中的 host 替换为 IP（仅当 baseUrl 包含该 host 时）→
/// 设置 [Host] 头为原始域名、写入 IP→域名映射供适配器做 SNI。
/// 结果：相对路径请求（如 get('/path')）时，Dio 最终请求 URL 为 IP，适配器建连用 IP、SNI/ Host 用域名；
/// 全路径请求或未替换时，适配器仍会用 HTTPDNS 解析后建连到 IP（解析失败才回退系统 DNS）。
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

      // 文档 5.3：resolveHostSyncNonBlocking(hostname, ipType)
      var res = await AliyunHttpdns.resolveHostSyncNonBlocking(
        host,
        ipType: 'ipv4',
      );
      var ipv4 = res['ipv4'] ?? [];

      // 首请求偶现“立即返回空”，短等后重试一次再降级
      if (ipv4.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 400));
        res = await AliyunHttpdns.resolveHostSyncNonBlocking(
          host,
          ipType: 'ipv4',
        );
        ipv4 = res['ipv4'] ?? [];
      }

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
        debugPrint('[HTTPDNS拦截器] 无解析结果 $host，本请求走适配器/系统 DNS');
      }
    } catch (e) {
      debugPrint('[HTTPDNS拦截器] 解析失败: $e，本请求走适配器/系统 DNS');
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
