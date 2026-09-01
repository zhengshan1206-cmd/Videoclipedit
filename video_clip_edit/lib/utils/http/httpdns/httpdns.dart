/// HTTPDNS功能模块 - 统一入口
///
/// 本模块提供HTTPDNS功能的统一访问接口，包括：
/// - HTTPDNS初始化和管理
/// - HTTPDNS适配器（用于Dio）
/// - HTTPDNS拦截器（用于Dio）
///
/// ```dart
/// // 初始化HTTPDNS
/// await HttpDnsManager.init(config);
///
/// // 获取HTTPDNS适配器
/// final adapter = buildHttpdnsHttpClientAdapter();
///
/// // 获取HTTPDNS拦截器
/// final interceptor = HttpDnsInterceptor();
/// ```

// 导出管理器
export 'httpdns_manager.dart';

// 导出适配器
export 'httpdns_adapter.dart';

// 导出拦截器
export 'httpdns_interceptor.dart';
