//  description:  dio工具类
import 'dart:async';
import 'dart:io';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:video_clip_edit/flavors/build_config.dart';

import 'apis.dart';
import 'dart:convert';
import 'log_utils.dart';
import 'error_handle.dart';
import 'package:dio/io.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_encrypt_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/http/httpdns/httpdns.dart';
import 'package:video_clip_edit/utils/http/route_history_manager.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

/// 默认dio配置
String _channel = BuildConfig.instance.channelType.channel;
String _baseUrl = APIs.apiPrefix;
Duration _connectTimeout = const Duration(seconds: 15);
Duration _receiveTimeout = const Duration(seconds: 15);
Duration _sendTimeout = const Duration(seconds: 10);
List<Interceptor> _interceptors = [];

typedef NetSuccessCallback<T> = Function(T data);
typedef NetSuccessListCallback<T> = Function(List<T> data);
typedef NetErrorCallback = Function(int code, String msg);

/// 初始化Dio配置
void configDio({
  Duration? connectTimeout,
  Duration? receiveTimeout,
  Duration? sendTimeout,
  String? baseUrl,
  List<Interceptor>? interceptors,
}) {
  _connectTimeout = connectTimeout ?? _connectTimeout;
  _receiveTimeout = receiveTimeout ?? _receiveTimeout;
  _sendTimeout = sendTimeout ?? _sendTimeout;
  _baseUrl = baseUrl ?? _baseUrl;
  _interceptors = interceptors ?? _interceptors;
}

class DioUtils {
  factory DioUtils() => _singleton;

  DioUtils._() {
    // 全局属性：请求前缀、连接超时时间、响应超时时间

    ///ios 里增加user-agent
    if (Platform.isIOS) {
      _httpHeaders[ConstKeys.kUserAgent] = ConstKeys.userAgentData;
    }
    // log("ios-header===> ${_httpHeaders.toString()}");

    final BaseOptions options = BaseOptions(
      /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
      /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
      /// 可以设置此选项为 “Headers.formUrlEncodedContentType”,  这样[Dio]就会自动编码请求体.
      /// contentType: Headers.formUrlEncodedContentType, // 适用于post form表单提交
      responseType: ResponseType.json,
      validateStatus: (status) {
        /// 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },
      baseUrl: _baseUrl,
      headers: _httpHeaders,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
    );
    _dio = Dio(options);

    // /// Fiddler抓包代理配置
    // dio.httpClientAdapter = IOHttpClientAdapter(
    //   createHttpClient: () {
    //     final client = HttpClient();
    //     client.findProxy = (uri) {
    //       // 将请求代理至 localhost:8888。
    //       // 请注意，代理会在你正在运行应用的设备上生效，而不是在宿主平台生效。
    //       return 'PROXY 192.168.3.165:8888';
    //     };
    //     // 抓Https包设置
    //     client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //     return client;
    //   },
    // );

    /// 配置HTTPDNS适配器（如果已初始化）
    var isTest =
        !LogUtils.inProduction || APIs.apiPrefix.startsWith('https://192');

    if (HttpDnsManager.isInitialized) {
      // 使用HTTPDNS适配器
      final adapter = buildHttpdnsHttpClientAdapter();
      if (isTest && ByPackageUtils.isMobile) {
        // 测试环境：忽略证书校验
        adapter.validateCertificate = (cert, host, port) => true;
      }
      _dio.httpClientAdapter = adapter;
    } else if (isTest && ByPackageUtils.isMobile) {
      // 如果HTTPDNS未初始化，使用默认适配器（测试环境忽略证书校验）
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    /// 添加拦截器
    void addInterceptor(Interceptor interceptor) {
      _dio.interceptors.add(interceptor);
    }

    _interceptors.forEach(addInterceptor);

    ///增加请求的重链
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print, // specify log function (optional)
        retries: 2, // retry count (optional)
        retryDelays: const [
          // set delays between retries (optional)
          Duration(seconds: 1), // wait 1 sec before the first retry
          Duration(seconds: 1), // wait 2 sec before the second retry
          // Duration(seconds: 3), // wait 3 sec before the third retry
          // Duration(seconds: 4), // wait 4 sec before the fourth retry
        ],
      ),
    );
  }

  static final DioUtils _singleton = DioUtils._();

  static DioUtils get instance => DioUtils();

  static late Dio _dio;

  Dio get dio => _dio;

  Future request<T>(
    Method method,
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    NetSuccessCallback? onSuccess,
    NetErrorCallback? onError,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      // // 没有网络
      // var connectivityResult = await (Connectivity().checkConnectivity());
      // // ignore: unrelated_type_equality_checks
      // if (connectivityResult == ConnectivityResult.none) {
      //   _onError(ExceptionHandle.net_error, '网络异常，请检查你的网络！', onError);
      //   return;
      // }

      ///检查是否有网络链接
      var connectivityResult = await (Connectivity().checkConnectivity());
      final List<ConnectivityResult> list = connectivityResult is List<ConnectivityResult>
          ? connectivityResult as List<ConnectivityResult>
          : <ConnectivityResult>[connectivityResult as ConnectivityResult];
      Get.log("===connectivityResult=== $list");
      if (list.isEmpty || list.first == ConnectivityResult.none) {
        _onError(ExceptionHandle.socket_error, '网络异常，请检查你的网络！', onError);
        return;
      }

      _updateHeaders();

      final Response response = await _dio.request<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _checkOptions(_methodValues[method], options),
        cancelToken: cancelToken,
      );
      onSuccess?.call(response.data);
    } catch (e, stackTrace) {
      // Dio 请求失败，记录异常便于排查 9999 等未知异常
      if (e is DioException) {
        final err = e.error;
        if (err is FormatException) {
          byDebugPrint(
            '接口返回 JSON 解析失败: $err',
            tag: '[Dio] ',
          );
          LogUtils.e('接口返回 JSON 解析失败: $err', tag: '[Dio] ');
          _onError(
            ExceptionHandle.parse_error,
            kNetSilentParseMsg,
            onError,
          );
          return;
        }
        byDebugPrint(
          'DioException type=${e.type} error=${e.error} response=${e.response?.statusCode}',
          tag: '[Dio] ',
        );
      }
      byDebugPrint(
        'Dio请求失败 url=$url type=${e.runtimeType} msg=$e',
        tag: '[Dio] ',
      );
      byDebugPrint('Dio请求失败 stackTrace: $stackTrace', tag: '[Dio] ');
      httpRequest(
        method,
        url,
        data: data,
        queryParameters: queryParameters,
        onError: onError,
        onSuccess: onSuccess,
      );
    }
  }

  void httpRequest(
    Method method,
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    NetSuccessCallback? onSuccess,
    NetErrorCallback? onError,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      url = _baseUrl + url;
      final headers = _updateHttpHeaders();
      Uri uri = Uri.parse(url);
      if (method == Method.post) {
        final response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(data),
        );
        onSuccess?.call(jsonDecode(response.body));
      } else if (method == Method.get) {
        if (queryParameters != null && queryParameters.isNotEmpty) {
          // 转换所有参数值为String类型
          final Map<String, String> safeQueryParams = {};
          queryParameters.forEach((key, value) {
            if (value == null) {
              safeQueryParams[key] = '';
            } else {
              safeQueryParams[key] = value.toString(); // 统一转为String
            }
          });
          uri = uri.replace(queryParameters: safeQueryParams);
        }
        final response = await http.get(uri, headers: headers);
        onSuccess?.call(jsonDecode(response.body));
      }
    } catch (e) {
      print('________二次请求网络异常$e');
      if (e is FormatException) {
        LogUtils.e('二次请求 JSON 解析失败: $e', tag: '[Dio] ');
        _onError(
          ExceptionHandle.parse_error,
          kNetSilentParseMsg,
          onError,
        );
        return;
      }
      final NetError error = ExceptionHandle.handleException(e);
      _onError(error.code, error.msg, onError);
    }
  }

  Map<String, String> _updateHttpHeaders() {
    Map<String, String> headers = {
      ConstKeys.kAccept: 'application/json,*/*',
      ConstKeys.kContentType: 'application/json',
      ConstKeys.kChannel: _channel,
    };
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final token = getToken();
    headers[ConstKeys.kToken] = token;
    headers[ConstKeys.kClientType] = "strong";
    headers[ConstKeys.kTimeStamp] = timestamp.toString();
    headers[ConstKeys.kAppFramework] = 'flutter';
    headers[ConstKeys.kAppVersion] =
        ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0";
    headers[ConstKeys.kSign] = _getSign(timestamp, token);

    // 添加路由信息到 header
    final routeManager = RouteHistoryManager.instance;
    final currentRoute = routeManager.getCurrentRoute();
    final previousRoute = routeManager.getPreviousRoute();
    headers['page_path'] = currentRoute;
    headers['pre_page_path'] = previousRoute;
    return headers;
  }

  void _updateHeaders() {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final token = getToken();
    _dio.options.headers[ConstKeys.kToken] = token;
    _dio.options.headers[ConstKeys.kClientType] = "strong";
    _dio.options.headers[ConstKeys.kTimeStamp] = timestamp;
    _dio.options.headers[ConstKeys.kAppFramework] = 'flutter';
    _dio.options.headers[ConstKeys.kAppVersion] =
        ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0";
    _dio.options.headers[ConstKeys.kSign] = _getSign(timestamp, token);

    // 添加路由信息到 header
    final routeManager = RouteHistoryManager.instance;
    final currentRoute = routeManager.getCurrentRoute();
    final previousRoute = routeManager.getPreviousRoute();
    _dio.options.headers['page_path'] = currentRoute;
    _dio.options.headers['pre_page_path'] = previousRoute;
  }
}

Options _checkOptions(String? method, Options? options) {
  options ??= Options();
  options.method = method;
  return options;
}

void _cancelLogPrint(dynamic e, String url) {
  if (e is DioException && CancelToken.isCancel(e)) {
    LogUtils.e('取消请求接口： $url');
  }
}

void _onError(int? code, String msg, NetErrorCallback? onError) {
  final int outCode = code ?? ExceptionHandle.unknown_error;
  String outMsg = msg;
  if (msg == kNetSilentParseMsg) {
    onError?.call(outCode, outMsg);
    return;
  }
  if (msg == '未知异常') {
    outMsg = '请求失败，请稍后重试';
  } else if (code == null && msg.trim().isEmpty) {
    outMsg = '请求失败，请稍后重试';
  }
  LogUtils.e('接口请求异常： code: $outCode, mag: $outMsg');
  onError?.call(outCode, outMsg);
}

/// 自定义Header
Map<String, dynamic> _httpHeaders = {
  ConstKeys.kAccept: 'application/json,*/*',
  ConstKeys.kContentType: 'application/json',
  ConstKeys.kChannel: _channel,
};

String _getSign(int timestamp, String token) {
  final sign = ByEncryptUtils.md5String("$timestamp$token");
  return sign;
}

Map<String, dynamic> parseData(String data) {
  return json.decode(data) as Map<String, dynamic>;
}

enum Method { get, post, put, patch, delete, head }

/// 使用：_methodValues[Method.post]
const _methodValues = {
  Method.get: 'get',
  Method.post: 'post',
  Method.delete: 'delete',
  Method.put: 'put',
  Method.patch: 'patch',
  Method.head: 'head',
};
