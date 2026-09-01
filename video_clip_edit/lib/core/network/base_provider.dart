import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/network/result.dart';
import 'package:video_clip_edit/core/util/logger.dart';
import 'package:video_clip_edit/data/model/response/base_response_entity.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/login/login_page.dart';
import 'package:video_clip_edit/modules/login/login_page_ex.dart';
import 'package:video_clip_edit/modules/profile/mine_score_page.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_scores_provider.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/channel/channel_config.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_encrypt_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/error_handle.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/http/route_history_manager.dart';

import '../../modules/login/controller/login_manager.dart';

typedef ConstructionAction<B> = B Function(dynamic data);

typedef DecoderAction<T, B> = T Function(
    dynamic data, ConstructionAction<B> construction);

class BaseProvider extends GetConnect {
  Worker? _userWorker;

  String? _token;

  final _headers = {
    ConstKeys.kAccept: 'application/json,*/*',
    ConstKeys.kContentType: 'application/json',
    ConstKeys.kChannel: BuildConfig.instance.channelType.channel,
  };

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = BuildConfig.instance.environment.domain;
    httpClient.timeout = const Duration(seconds: 15);
    httpClient.defaultDecoder = _networkDefaultDecoder;
  }

  void _updateHeaders() {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    _headers[ConstKeys.kToken] = getToken();
    _headers[ConstKeys.kClientType] = "strong";
    _headers[ConstKeys.kTimeStamp] = '$timestamp';
    _headers[ConstKeys.kAppFramework] = 'flutter';
    _headers[ConstKeys.kAppVersion] =
        ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0";
    _headers[ConstKeys.kSign] = _getSign(timestamp);

    // 添加路由信息到 header
    final routeManager = RouteHistoryManager.instance;
    final currentRoute = routeManager.getCurrentRoute();
    final previousRoute = routeManager.getPreviousRoute();
    _headers[ConstKeys.kPagePath] = currentRoute;
    _headers[ConstKeys.kPrePagePath] = previousRoute;
  }

  String _getSign(int timestamp) {
    final token = getToken();
    final sign = ByEncryptUtils.md5String("$timestamp$token");
    return sign;
  }

  Future<Result<T, APIError>> getRequest<T extends APIEntity, B>({
    required String url,
    Map<String, dynamic>? query,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
    String? contentType,
    Map<String, String>? headers,
    Progress? uploadProgress,
  }) async {
    BYDebugPrint(
      "Request start\nmethod: GET\nurl: ${(httpClient.baseUrl ?? "") + url}\nparameters: $query\nTOKEN:$_token",
      needSplit: true,
    );

    // 没有网络
    var connectivityResult = await (Connectivity().checkConnectivity());
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) {
      return Result.failure(APIError(
        '网络异常，请检查你的网络！',
        ExceptionHandle.net_error,
      ));
    }

    _updateHeaders();

    final response = await super.get(
      url,
      headers: headers ?? _headers,
      contentType: contentType,
      query: query,
      decoder: (data) => decoder(data, construction),
    );
    return _responseHandler(
        method: "GET", url: url, parameters: query, response: response);
  }

  Future<Result<T, APIError>> postRequest<T extends APIEntity, B>({
    required String url,
    dynamic body,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
    String? contentType,
    Map<String, String>? headers,
    Progress? uploadProgress,
  }) async {
    BYDebugPrint(
      "Request start\nmethod: POST\nurl: ${(httpClient.baseUrl ?? "") + (url)}\nparameters: $body\nTOKEN:$_token",
      needSplit: true,
    );
    final response = await super.post(
      url,
      body,
      contentType: contentType,
      headers: headers ?? _headers,
      decoder: (data) => decoder(data, construction),
      uploadProgress: uploadProgress,
    );
    return _responseHandler(
        method: "POST", url: url, parameters: body, response: response);
  }

  Future<Result<T, APIError>> deleteRequest<T extends APIEntity, B>({
    required String url,
    Map<String, dynamic>? query,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
    String? contentType,
    Map<String, String>? headers,
    Progress? uploadProgress,
  }) async {
    BYDebugPrint(
      "Request start\nmethod: DELETE\nurl: ${(httpClient.baseUrl ?? "") + url}\nparameters: $query\nTOKEN:$_token",
      needSplit: true,
    );
    final response = await super.delete(
      url,
      headers: headers ?? _headers,
      contentType: contentType,
      query: query,
      decoder: (data) => decoder(data, construction),
    );
    return _responseHandler(
        method: "DELETE", url: url, parameters: query, response: response);
  }

  Future<Result<T, APIError>> putRequest<T extends APIEntity, B>({
    required String url,
    body,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
    String? contentType,
    Map<String, String>? headers,
    Progress? uploadProgress,
  }) async {
    BYDebugPrint(
      "Request start\nmethod: PUT\nurl: ${(httpClient.baseUrl ?? "") + (url)}\nparameters: $body\nTOKEN:$_token",
      needSplit: true,
    );
    final response = await super.put(
      url,
      body,
      contentType: contentType,
      headers: headers ?? _headers,
      decoder: (data) => decoder(data, construction),
      uploadProgress: uploadProgress,
    );
    return _responseHandler(
        method: "PUT", url: url, parameters: body, response: response);
  }

  Future<Result<T, APIError>>
      _responseHandler<T extends APIEntity, B extends APIEntity>({
    required String method,
    required String url,
    required dynamic parameters,
    required Response<T> response,
  }) async {
    if (response.hasError) {
      APIError error;
      if (response.status.connectionError) {
        error = APIError(APIEntity.conncetErrorMsg, APIEntity.connectErrorCode);
      } else {
        error = APIError(
          response.statusText ?? APIEntity.unknownErrorMsg,
          response.statusCode ?? APIEntity.unknownErrorCode,
        );
      }
      BYDebugPrint(
        "Response error\nmethod: $method\nurl: ${(httpClient.baseUrl ?? "") + (url)}\nparameters: $parameters\nTOKEN:$_token\nerror:${error.toString()}",
        needSplit: true,
      );
      return Result.failure(error);
    } else {
      final body = response.body;
      if (body?.isSuccess() ?? false) {
        BYDebugPrint(
          "Response success\nmethod: $method\nurl: ${(httpClient.baseUrl ?? "") + (url)}\nparameters: $parameters\nTOKEN:$_token\nresponse:${response.bodyString}",
          needSplit: true,
        );
        return Result.succss(body!);
      } else if (body?.isSpecialSuccessOne() ?? false) {
        ///显示登录页面
        LoginManager.showLoginPage(useSafeArea: true);
        final error = body!.error!;
        return Result.failure(error, responseData: body);
      } else if (body?.isSpecialSuccessTwo() ?? false) {
        Get.context!.read<PurchaseProvider>().loadVIPItems(
          onSuccess: () {
            showDialog(
              context: Get.context!,
              builder: (context) {
                return const DailogBonusLowestPrice();
              },
            );
          },
        );
        final error = body!.error!;
        return Result.failure(error, responseData: body);
      } else if (body?.isSpecialSuccessThree() ?? false) {
        showDialog(
          context: Get.context!,
          builder: (context) {
            return const DailogBonusLowestPrice();
            // return CommonDialog(
            //   reverse: false,
            //   maxLine: 10,
            //   contents: "当前积分不足，是否前往充值？",
            //   confirmBtnTitle: "确定",
            //   confirmCallback: () {
            //     ByNavRouterUtils.push(
            //       context,
            //       MultiProvider(
            //         providers: [
            //           ChangeNotifierProvider(
            //               create: (BuildContext context) => MinePageProvider()),
            //           ChangeNotifierProvider(
            //               create: (ctx) => MineScoresProvider()),
            //         ],
            //         child: const MineScorePage(),
            //       ),
            //     );
            //   },
            // );
          },
        );
        final error = body!.error!;
        return Result.failure(error, responseData: body);

        ///TODO
      } /*else if (forceData) {
        success?.call(result);
      } else {
        // 其他状态，弹出错误提示信息
        if (showMsgWhenFailed) {
          ByProgressHUD.showText(result['message']);
        }
        fail?.call(result['status'] ?? result["code"], result['message']);
      } */
      else {
        final error = body!.error!;
        BYDebugPrint(
          "Response error\nmethod: $method\nurl: ${(httpClient.baseUrl ?? "") + (url)}\nparameters: $parameters\nTOKEN:$_token\nerror:${error.toString()}",
          needSplit: true,
        );

        ///TODO
        // if (error.code == TokenInvalidationCode) {
        //   _userController.doLogout();
        // }
        return Result.failure(error, responseData: body);
      }
    }
  }

  /// 默认返回值解析
  BaseEntity? _networkDefaultDecoder(data) {
    if (data is Map<String, dynamic>) {
      return BaseEntity.fromJson(data, (data) => VoidObject.fromJson(data));
    }
    return null;
  }

  T decoderWithPrint<T extends APIEntity, B>({
    required String url,
    dynamic data,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
  }) {
    BYDebugPrint(
      "Request end\nurl: ${(httpClient.baseUrl ?? "") + url}\nresponseData: $data",
      needSplit: true,
    );
    return decoder(data, construction);
  }

  @override
  void onClose() {
    super.onClose();
    _userWorker?.dispose();
  }
}
