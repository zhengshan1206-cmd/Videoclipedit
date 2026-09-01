//  description: 网络请求工具类（dio二次封装）
// ignore_for_file: avoid_print
import 'dart:io';
import 'package:video_clip_edit/utils/comon/by_ascribe_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_events.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import '../../widgets/toast_util.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'apis.dart';
import 'intercept.dart';
import 'log_utils.dart';
import 'dio_utils.dart';
import 'error_handle.dart';
import 'httpdns/httpdns.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:dio/dio.dart';
import 'package:video_clip_edit/main.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/widgets/by_progress_hud.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

typedef Success<T> = Function(T data);
typedef Fail = Function(int code, String msg);

// 日志开关
const bool isOpenLog = true;
const bool isOpenAllLog = true;

class HttpUtils {
  /// 调用业务 success；解析异常仅打日志，不触发 fail / Toast。
  static void _safeInvokeSuccess(Success? success, dynamic result) {
    if (success == null) return;
    try {
      success(result);
    } catch (e, st) {
      byDebugPrint('接口数据解析异常: $e\n$st', tag: '[HTTP] ');
      LogUtils.e('接口数据解析异常: $e\n$st', tag: '[HTTP] ');
    }
  }

  /// dio基础初始化（不包含HTTPDNS，避免在用户同意隐私政策前进行网络请求）
  static void initDioBasic() {
    final List<Interceptor> interceptors = <Interceptor>[];

    /// 统一添加身份验证请求头
    interceptors.add(AuthInterceptor());

    /// 刷新Token
    // interceptors.add(TokenInterceptor());

    /// 打印Log(生产模式去除)
    // if (!LogUtils.inProduction && isOpenAllLog) {
    //   interceptors.add(LoggingInterceptor()); // 调试打开
    // }

    interceptors.add(LoggingInterceptor()); // 调试打开

    configDio(baseUrl: APIs.apiPrefix, interceptors: interceptors);

    // 不初始化HTTPDNS，等待用户同意隐私政策后再初始化
  }

  /// dio main函数初始化（包含HTTPDNS初始化）
  static void initDio() {
    final List<Interceptor> interceptors = <Interceptor>[];

    /// 统一添加身份验证请求头
    interceptors.add(AuthInterceptor());

    /// 刷新Token
    // interceptors.add(TokenInterceptor());

    /// 打印Log(生产模式去除)
    // if (!LogUtils.inProduction && isOpenAllLog) {
    //   interceptors.add(LoggingInterceptor()); // 调试打开
    // }

    interceptors.add(LoggingInterceptor()); // 调试打开

    configDio(baseUrl: APIs.apiPrefix, interceptors: interceptors);

    // 初始化HTTPDNS（独立功能模块，不影响其他功能）
    _initHttpDns();
  }

  /// 用户同意隐私政策后，初始化HTTPDNS
  static Future<void> initHttpDnsAfterPrivacyAgreed() async {
    await _initHttpDns();
  }

  /// 初始化HTTPDNS（独立功能模块）
  /// 鸿蒙版本不使用阿里云 HTTPDNS，直接走系统 DNS
  static Future<void> _initHttpDns() async {
    if (ByPackageUtils.isOhos) return;

    try {
      // HTTPDNS配置
      const config = HttpDnsConfig(
        accountId: 149394,
        secretKey: '93d992c2bec875d0b6032e347980d5dc',
        aesSecretKey: 'f1f97564926b3cbb8c51756825491fbf',
        enableHttps: true,
        enableLog: true,
        enablePersistentCache: true,
        enableReuseExpiredIp: true,
        enablePreResolveAfterNetworkChanged: true,
      );

      // 异步初始化，不阻塞主流程
      final success = await HttpDnsManager.init(config);
      if (success) {
        byDebugPrint('HTTPDNS初始化完成', tag: '[HTTPDNS] ');

        // HTTPDNS初始化完成后，更新Dio适配器以使用HTTPDNS
        _updateDioAdapterForHttpDns();

        // 同时添加HTTPDNS拦截器（作为备用方案）
        _addHttpDnsInterceptor();
      }
    } catch (e) {
      // HTTPDNS初始化失败不影响其他功能
      byDebugPrint('HTTPDNS初始化异常: $e', tag: '[HTTPDNS] ');
    }
  }

  /// 更新Dio适配器以使用HTTPDNS
  static void _updateDioAdapterForHttpDns() {
    try {
      final dio = DioUtils.instance.dio;
      final isTest =
          !LogUtils.inProduction || APIs.apiPrefix.startsWith('https://192');

      byDebugPrint('开始更新Dio适配器为HTTPDNS适配器', tag: '[HTTPDNS] ');
      byDebugPrint(
        '当前适配器类型: ${dio.httpClientAdapter.runtimeType}',
        tag: '[HTTPDNS] ',
      );

      // 使用HTTPDNS适配器
      final adapter = buildHttpdnsHttpClientAdapter();
      if (isTest && ByPackageUtils.isMobile) {
        // 测试环境：忽略证书校验
        adapter.validateCertificate = (cert, host, port) => true;
      }

      // 强制设置适配器，确保使用HTTPDNS
      dio.httpClientAdapter = adapter;

      byDebugPrint(
        '适配器已更新，新适配器类型: ${dio.httpClientAdapter.runtimeType}',
        tag: '[HTTPDNS] ',
      );
      byDebugPrint('Dio适配器已更新为HTTPDNS适配器', tag: '[HTTPDNS] ');
      byDebugPrint('当前Dio baseUrl: ${dio.options.baseUrl}', tag: '[HTTPDNS] ');
    } catch (e) {
      byDebugPrint('更新Dio适配器失败: $e', tag: '[HTTPDNS] ');
      byDebugPrint('错误堆栈: ${StackTrace.current}', tag: '[HTTPDNS] ');
    }
  }

  /// 添加HTTPDNS拦截器
  static void _addHttpDnsInterceptor() {
    try {
      final dio = DioUtils.instance.dio;
      // 检查是否已经添加了HTTPDNS拦截器
      final hasInterceptor = dio.interceptors.any(
        (interceptor) => interceptor is HttpDnsInterceptor,
      );

      if (!hasInterceptor) {
        // 在第一个位置添加HTTPDNS拦截器，确保在其他拦截器之前执行
        dio.interceptors.insert(0, HttpDnsInterceptor());
        byDebugPrint('HTTPDNS拦截器已添加', tag: '[HTTPDNS] ');
      }
    } catch (e) {
      byDebugPrint('添加HTTPDNS拦截器失败: $e', tag: '[HTTPDNS] ');
    }
  }

  static setBaseUrl(String baseUrl) {
    DioUtils.instance.dio.options.baseUrl = baseUrl;
  }

  /// get 请求
  static void get<T>(
    String url,
    Map<String, dynamic>? params, {
    String? loadingText,
    Success? success,
    bool? showLoading,
    CancelToken? cancelToken,
    bool forceData = false,
    bool showMsgWhenFailed = true,
    Fail? fail,
  }) {
    request(
      Method.get,
      url,
      params,
      forceData: forceData,
      showMsgWhenFailed: showMsgWhenFailed,
      loadingText: loadingText,
      cancelToken: cancelToken,
      showLoading: showLoading,
      success: success,
      fail: fail,
    );
  }

  /// post 请求
  static void post<T>(
    String url,
    params, {
    String? loadingText,
    bool? showLoading,
    Options? options,
    CancelToken? cancelToken,
    bool forceData = false,
    bool showMsgWhenFailed = true,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.post,
      url,
      params,
      forceData: forceData,
      showMsgWhenFailed: showMsgWhenFailed,
      loadingText: loadingText,
      showLoading: showLoading,
      cancelToken: cancelToken,
      success: success,
      fail: fail,
    );
  }

  /// 轮询请求方法
  /// [method] - 请求方法(GET/POST)
  /// [url] - 请求地址
  /// [data] - POST请求数据
  /// [queryParameters] - GET请求参数
  /// [checkSuccess] - 检查响应是否成功的回调
  /// [onSuccess] - 成功回调
  /// [onError] - 错误回调
  /// [cancelToken] - 取消令牌
  /// [maxAttempts] - 最大尝试次数,默认无限循环
  static Future<void> startPolling({
    required Method method,
    required String url,
    params,
    Map<String, dynamic>? queryParameters,
    required bool Function(dynamic response) checkSuccess,
    Function(dynamic response)? onSuccess,
    Function(int code, String msg)? onError,
    CancelToken? cancelToken,
    int currentAttempts = 0,
    int? maxAttempts,
  }) async {
    if (maxAttempts == null || currentAttempts < maxAttempts) {
      Object? data;
      if (method == Method.get) {
        queryParameters = params;
      }
      if (method == Method.post) {
        data = params;
      }
      try {
        await DioUtils.instance.request(
          method,
          url,
          data: data,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onSuccess: (response) {
            if (checkSuccess(response)) {
              onSuccess?.call(response);
              return;
            }
            _retryAfterDelay(
              method: method,
              url: url,
              data: params,
              queryParameters: queryParameters,
              checkSuccess: checkSuccess,
              onSuccess: onSuccess,
              onError: onError,
              cancelToken: cancelToken,
              maxAttempts: maxAttempts,
              currentAttempts: currentAttempts + 1,
            );
          },
          onError: (code, msg) {
            onError?.call(code, msg);
            _retryAfterDelay(
              method: method,
              url: url,
              data: params,
              queryParameters: queryParameters,
              checkSuccess: checkSuccess,
              onSuccess: onSuccess,
              onError: onError,
              cancelToken: cancelToken,
              maxAttempts: maxAttempts,
              currentAttempts: currentAttempts + 1,
            );
          },
        );
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) return;
        _retryAfterDelay(
          method: method,
          url: url,
          data: data,
          queryParameters: queryParameters,
          checkSuccess: checkSuccess,
          onSuccess: onSuccess,
          onError: onError,
          cancelToken: cancelToken,
          maxAttempts: maxAttempts,
          currentAttempts: currentAttempts + 1,
        );
      }
    }
  }

  /// 轮询间隔
  static const int _pollingInterval = 3000;

  /// 轮询请求重试
  static void _retryAfterDelay({
    required Method method,
    required String url,
    required Object? data,
    required Map<String, dynamic>? queryParameters,
    required bool Function(dynamic) checkSuccess,
    required Function(dynamic)? onSuccess,
    required Function(int code, String msg)? onError,
    required CancelToken? cancelToken,
    required int? maxAttempts,
    required int currentAttempts,
  }) {
    Future.delayed(
      const Duration(milliseconds: _pollingInterval),
      () => startPolling(
        method: method,
        url: url,
        params: data,
        queryParameters: queryParameters,
        checkSuccess: checkSuccess,
        onSuccess: onSuccess,
        onError: onError,
        cancelToken: cancelToken,
        maxAttempts: maxAttempts,
      ),
    );
  }

  /// _request 请求
  static void request<T>(
    Method method,
    String url,
    params, {
    bool? showLoading,
    CancelToken? cancelToken,
    String? loadingText = '加载中...',
    Success? success,
    required bool forceData,
    required bool showMsgWhenFailed,
    Fail? fail,
    Function(dynamic)? response,
    Options? options,
  }) {
    // byDebugPrint("header====> ");
    // 参数处理（如果需要加密等统一参数）
    if (!LogUtils.inProduction && isOpenLog) {
      byDebugPrint('---------- HttpUtils URL ----------$showLoading');
      byDebugPrint(url);
      byDebugPrint('---------- HttpUtils params ----------$showLoading');
      byDebugPrint(params);
    }

    Object? data;
    Map<String, dynamic>? queryParameters;
    if (method == Method.get) {
      queryParameters = params;
    }
    if (method == Method.post) {
      data = params;
    }
    if (showLoading == true) {
      EasyLoading.show(status: loadingText);
    }

    DioUtils.instance.request(
      method,
      url,
      data: data,
      options: options,
      cancelToken: cancelToken,
      queryParameters: queryParameters,
      onSuccess: (result) {
        // if (!LogUtils.inProduction && isOpenLog) {
        //   byDebugPrint('---------- HttpUtils response ----------$url');
        //   byDebugPrint(result);
        // }
        response?.call(result);
        if (result is Map && result.containsKey('byuniplugin')) {
          final byunipluginValue = result['byuniplugin'];
          try {
            List<dynamic>? pluginList;
            // 兼容处理：如果是 List，直接使用；如果是 Map，包装成 List；其他类型忽略
            if (byunipluginValue is List) {
              pluginList = byunipluginValue;
            } else if (byunipluginValue is Map) {
              // 如果是单个 Map，包装成 List
              pluginList = [byunipluginValue];
            } else {
              // 其他类型，记录日志但不处理
              byDebugPrint(
                'byuniplugin 类型不支持，期望 List 或 Map，实际类型: ${byunipluginValue.runtimeType}',
                tag: '[HTTP]',
              );
            }

            // 只有当 pluginList 不为空时才处理
            if (pluginList != null) {
              ByAscribeUtil.byuniplugin(pluginList);
            }
          } catch (e) {
            byDebugPrint('处理 byuniplugin 时发生错误: $e', tag: '[HTTP]');
          }
        }
        if (showLoading == true) {
          EasyLoading.dismiss();
        }

        // 确保result是Map类型，避免类型错误
        if (result is! Map) {
          byDebugPrint('接收到非JSON响应: $result', tag: '[HTTPDNS] ');
          LogUtils.e('接收到非JSON响应: $result', tag: '[HTTP] ');
          return;
        }

        if (result['status'] == ExceptionHandle.success) {
          _safeInvokeSuccess(success, result);
        } else if (result['status'] == ResponseCode.loginRequired) {
          final context = navigatorKey.currentContext;

          ///显示登录页面
          // LoginManager.showLoginPage(isScrollControlled: false);
          fail?.call(result['status'] ?? result["code"], result['message']);
        } else if (result['status'] == ResponseCode.vipPromote) {
          ///vip特价弹窗
          // final context = navigatorKey.currentContext;
          // context!.read<PurchaseProvider>().loadVIPItems(
          //   onSuccess: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return const DailogBonusLowestPrice();
          //       },
          //     );
          //   },
          // );
          fail?.call(result['status'] ?? result["code"], result['message']);
        } else if (result['status'] == ResponseCode.pointsNotEnough) {
          ///积分不足
          // final context = navigatorKey.currentContext;
          // context!.read<PurchaseProvider>().loadVIPItems(
          //   onSuccess: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return const DailogBonusLowestPrice();
          //       },
          //     );
          //   },
          // );
          fail?.call(result['status'] ?? result["code"], result['message']);
        } else if (forceData) {
          _safeInvokeSuccess(success, result);
        } else {
          // 其他状态，弹出错误提示信息
          if (showMsgWhenFailed) {
            // ByProgressHUD.showText(result['message']);
          }
          fail?.call(result['status'] ?? result["code"], result['message']);
        }
      },
      onError: (code, msg) {
        if (showLoading == true) {
          ByProgressHUD.hide();
          EasyLoading.dismiss();
        }

        if (code == ExceptionHandle.parse_error && msg == kNetSilentParseMsg) {
          return;
        }

        if (code == 1002) {
          ToastUtil().showToast(msg);
          // fail?.call(code, msg);
          eventBus.fire(const NetworkErrorEvent());
          return;
        }

        // ByProgressHUD.showError(msg);
        final displayMsg =
            (code == ExceptionHandle.unknown_error && msg == '未知异常')
                ? '请求失败，请稍后重试'
                : msg;
        fail?.call(code, displayMsg);
      },
    );
  }
}

class ResponseCode {
  /// vip特价弹窗
  static int vipPromote = 1002;

  /// 未登录
  static int loginRequired = 2001;

  /// 积分不足
  static int pointsNotEnough = 1000001;
}
