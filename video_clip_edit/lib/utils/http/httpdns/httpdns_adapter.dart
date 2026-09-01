// HTTPDNS适配器 - 无阿里云 SDK 时使用默认 Dio 适配器，走系统 DNS
import 'package:dio/io.dart';

// 全局映射：IP地址 -> 原始域名（拦截器写入；无 HTTPDNS 时通常为空）
final Map<String, String> _ipToDomainMap = {};

/// 设置 IP->域名映射（供拦截器调用）
void setIpDomainMapping(String ip, String domain) {
  _ipToDomainMap[ip] = domain;
}

/// 清除 IP->域名映射
void clearIpDomainMapping() {
  _ipToDomainMap.clear();
}

/// 构建 Dio 适配器（当前为默认 IOHttpClientAdapter，走系统 DNS）
IOHttpClientAdapter buildHttpdnsHttpClientAdapter() {
  return IOHttpClientAdapter()..validateCertificate = (cert, host, port) => true;
}
