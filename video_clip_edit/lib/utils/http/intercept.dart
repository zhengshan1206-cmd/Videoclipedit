//  description:  拦截器
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_encrypt_utils.dart';

import 'apis.dart';
import 'log_utils.dart';
import 'error_handle.dart';
import 'package:dio/dio.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/utils/http/route_history_manager.dart';

// default token
const String defaultToken = '';

String getToken() {
  var token = ByStorageUtils.getString(ConstKeys.kToken) ?? defaultToken;
  return token;
}

Future<bool>? setToken(token) {
  return ByStorageUtils.saveString(ConstKeys.kToken, token);
}

String getRefreshToken() {
  var refreshToken = ByStorageUtils.getString('refreshToken') ?? '';
  return refreshToken;
}

void setRefreshToken(refreshToken) {
  ByStorageUtils.saveString('refreshToken', refreshToken);
}

/// 统一添加身份验证请求头（根据项目自行处理）
class AuthInterceptor extends Interceptor {
  final RouteHistoryManager _routeManager = RouteHistoryManager.instance;

  String _getSign(int timestamp) {
    final token = getToken();
    final sign = ByEncryptUtils.md5String("$timestamp$token");
    return sign;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加路由信息到 header
    final currentRoute = _routeManager.getCurrentRoute();
    final previousRoute = _routeManager.getPreviousRoute();
    options.headers[ConstKeys.kPagePath] = currentRoute;
    options.headers[ConstKeys.kPrePagePath] = previousRoute;

    byDebugPrint("currentRoute: $currentRoute, previousRoute: $previousRoute",
        tag: "OnRequest:");
    byDebugPrint("routeHistory: ${_routeManager.getRouteHistory()}",
        tag: "OnRequest:");

    if (_shouldAttachAuth(options.path, options.extra)) {
      final String token = getToken();
      if (token.isNotEmpty) {
        byDebugPrint("update token: $token", tag: "OnRequest:");
        final timestamp =
            (DateTime.now().millisecondsSinceEpoch / 1000).floor();
        options.headers[ConstKeys.kToken] = getToken();
        options.headers[ConstKeys.kTimeStamp] = timestamp;
        options.headers[ConstKeys.kSign] = _getSign(timestamp);
      }
    }
    super.onRequest(options, handler);
  }

  bool _shouldAttachAuth(String path, Map<String, dynamic> extra) {
    if (extra['skipAuth'] == true) return false;
    if (path == APIs.launch || path == APIs.sendVCode) return false;
    return true;
  }
}

/// 打印日志
class LoggingInterceptor extends Interceptor {
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    LogUtils.d('-------------------- Start --------------------');
    if (options.queryParameters.isEmpty) {
      LogUtils.d('RequestUrl: ${options.baseUrl}${options.path}');
    } else {
      LogUtils.d(
          'RequestUrl: ${options.baseUrl}${options.path}?${Transformer.urlEncodeMap(options.queryParameters)}');
    }
    LogUtils.d('RequestMethod: ${options.method}');
    LogUtils.d('RequestHeaders:${options.headers}');
    LogUtils.d('RequestContentType: ${options.contentType}');
    LogUtils.d('RequestData: ${options.data.toString()}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    _endTime = DateTime.now();
    final int duration = _endTime.difference(_startTime).inMilliseconds;
    if (response.statusCode == ExceptionHandle.success) {
      LogUtils.d('ResponseCode: ${response.statusCode}');
    } else {
      LogUtils.e('ResponseCode: ${response.statusCode}');
    }
    // 输出结果
    LogUtils.d('返回数据：${response.data}');
    LogUtils.d('-------------------- End: $duration 毫秒 --------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LogUtils.d('-------------------- Error --------------------');
    super.onError(err, handler);
  }
}
