// ignore_for_file: undefined_named_parameter
import 'dart:convert';

// import 'package:bda_signal/bda_signal.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_ascribe_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/http/dio_utils.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_device_info_utils.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/v2/business/ios_purchase_half_dialog.dart';
import 'package:video_clip_edit/v2/business/purchase_half_dialog.dart';

import '../modules/main/controllers/logger.service.dart';

typedef LaunchSuccessCallback = void Function(LaunchInfoBean);
typedef LaunchFailCallback = void Function();

class LaunchProvider extends BaseProvider {
  LaunchInfoBean? launchInfo;

  int value = 1;
  bool clipGuidHasBeenShown = false;
  bool recreateGuidHasBeenShown = false;

  ///是否是民间故事支付回调
  bool isFolkStoryPayback = false;

  ///付费页面参数配置 pay_page_id  top_operate_material_ id
  String? payPageId;
  String? topOperateMaterialId;

  /// 最后一次启动接口的请求结果
  dynamic lastLaunchResult;

  /// 最后一次启动接口的错误信息
  int? lastLaunchErrorCode;
  String? lastLaunchErrorMsg;
  dynamic launchResponseData;

  launch(
    BuildContext context, {
    LaunchSuccessCallback? onSuccess,
    LaunchFailCallback? onFail,
    Function(int)? progress,
    bool? isFirstIn = false,
  }) async {
    Map params = {};
    try {
      final imei = await ByDeviceInfoUtils.deviceInfo();
      String system = Consts.kSystemAndroid;
      if (ByPackageUtils.isAndroid) {
        system = Consts.kSystemAndroid;
      } else if (ByPackageUtils.isIOS) {
        system = Consts.kSystemIOS;
      } else if (ByPackageUtils.isOhos) {
        system = 'harmony';
      }
      params = {
        "uuid": imei.item2,
        "app_version":
            ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0",
        "sys": system,
      };
      byDebugPrint(params, tag: "launch params");
      progress?.call(15);
    } catch (e) {
      uploadLaunchError(200, 'success', isFirstIn!, params, 10);
    }

    // 清空上次的结果
    lastLaunchResult = null;
    lastLaunchErrorCode = null;
    lastLaunchErrorMsg = null;

    HttpUtils.request(
      Method.post,
      APIs.launch,
      forceData: false,
      showMsgWhenFailed: true,
      params,
      success: (data) async {
        // 保存请求结果
        lastLaunchResult = data;
        lastLaunchErrorCode = null;
        lastLaunchErrorMsg = null;
        progress?.call(20);

        String token = '';
        LaunchInfoBean? launchInfoBean;
        try {
          final responseData = data["data"];
          launchInfoBean = LaunchInfoBean.fromJson(responseData);
          launchInfo = launchInfoBean;
          token = launchInfoBean.token;
        } catch (e) {
          uploadLaunchError(200, 'success', isFirstIn!, params, 20);
        }

        progress?.call(25);

        /// 保存token
        setToken(token)?.then((onValue) {
          if (onValue) {
            progress?.call(30);
            try {
              /// 上报设别信息
              DeviceInfoUpload.uploadUserDeviceInfo();
              progress?.call(35);

              /// 回调
              onSuccess?.call(launchInfoBean!);
            } catch (e) {
              uploadLaunchError(200, 'success', isFirstIn!, params, 35);
            }

            notifyListeners();
          }
        });
      },
      response: (data) {
        launchResponseData = data;
      },
      fail: (code, msg) {
        /*
        1.超时
        2.有response，（格式不对，code 非200）
        3.用户网络原因

        上报日志（附加参数 1.用户网络情况 2.是否首次 3设备信息 4.接口请求response）
        */
        // 保存错误信息
        lastLaunchResult = null;
        lastLaunchErrorCode = code;
        lastLaunchErrorMsg = msg;

        ByCommonUtils.debugPrintObj("onError: code: $code");
        ByCommonUtils.debugPrintObj("onError: msg: $msg");
        FlutterBugly.uploadException(
          message: "启动接口失败: $code: $msg",
          detail: msg,
        );
        uploadLaunchError(code, msg, isFirstIn!, params, 15);
        onFail?.call();
      },
    );
  }

  //// 上报launch失败信息
  void uploadLaunchError(
    int code,
    String msg,
    bool isFirstIn,
    Map params,
    int progresss,
  ) async {
    launchResponseData = launchResponseData ?? '';
    final errorMsg = {
      'code': code,
      'msg': msg,
      'first_in': isFirstIn,
      'network': await ByDeviceInfoUtils.getNetworkStatus(),
      'launch_params': params,
      'response': launchResponseData,
      'progress': progresss,
    };
    LoggerService.sendLog(
      url: '/novel/log/create?security=aohlpsihnt53kasdhflkihn',
      tag: 'launch',
      log: jsonEncode(errorMsg),
    );
  }

  shouldShowClipGuid() {
    final bool isVip = launchInfo?.isVip == 1;
    return !(isVip || clipGuidHasBeenShown);
  }

  checkClipGuid() {
    clipGuidHasBeenShown = true;
    notifyListeners();
  }

  shouldShowCreateGuid() {
    final bool isVip = launchInfo?.isVip == 1;
    return !(isVip || recreateGuidHasBeenShown);
  }

  checkCreateGuid() {
    recreateGuidHasBeenShown = true;
    notifyListeners();
  }

  gotoPay(
    BuildContext context, {
    bool? closePay,
    bool replace = false,
    bool needCheckLogin = true,
    VoidCallback? cancelLogin,
  }) {
    ///在这里需要针对华为未绑定手机号码做一次检测
    ///3.10.30修改支付页都需要强拉是否登录
    ///提取跳转逻辑为公共方法，避免重复代码
    void navigateToPayPage() {
      String landingPage = launchInfo?.verConfig.landingPage ?? "";
      Get.log("后台下发要去的页面==> $landingPage");
      if (![
        "/rechargeOld",
        "/rechargeNew",
        "/rechargeMbgf",
        "/rechargeMbgf2",
        "/rechargeMbgf3",
        "/rechargeMbgf4",
        "/rechargeMbgf5",
      ].contains(landingPage)) {
        landingPage = "/rechargeMbgf";
      }
      if (replace) {
        ByNavRouterUtils.pushReplacementNamed(
          context,
          landingPage,
          arguments: closePay,
        );
      } else {
        ByNavRouterUtils.pushNamed(context, landingPage, arguments: closePay);
      }
    }

    if (needCheckLogin) {
      ///需要检查登录，先检查登录状态，登录成功后再跳转
      ByNavigatorUtil.checkLogin(
        context: context,
        cancelLogin: cancelLogin,
        nextStepEvent: () {
          final UserController controller = Get.find<UserController>();
          UserInfoBean? userInfo = controller.user.value;
          if (userInfo?.isVip == 1 &&
              Get.isRegistered<NewUserBenefitsController>() == true) {
            Get.find<NewUserBenefitsController>().hideBottom();
          }
          navigateToPayPage();
        },
      );
    } else {
      ///不需要检查登录，直接跳转到支付页面
      navigateToPayPage();
    }
  }

  ///付费半弹窗顶部图片
  List<SubFunction> modulesPayTopList = [];

  ///获取付费半弹窗顶部图片
  loadPayTopList() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 20},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        debugPrint("获取付费半弹窗顶部图片:$bannerData");
        byDebugPrint(bannerData, tag: "获取付费半弹窗顶部图片:");
        if (bannerData.isNotEmpty) {
          List<SubFunction> beans =
              bannerData.map((e) => SubFunction.fromJson(e)).toList();
          modulesPayTopList = beans;
        } else {
          modulesPayTopList = [];
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  //匹配付费半弹窗
  ///[mark] 付费半弹窗的匹配标识
  showPayHalfDialog(
    context,
    String mark, {
    String? themeId,
    String eventFunction = "",
    String pagePath = "",
    String prePagePath = "",
  }) {
    String bgImgUrl = "assets/purchase/half_pop_bg.png";
    if (modulesPayTopList.isNotEmpty) {
      SubFunction? findItemOrReturnNull(
        List<SubFunction> items,
        String searchString,
      ) {
        try {
          return items.firstWhere(
            (item) => themeId?.isNotEmpty == true
                ? item.jumpUrl == searchString && item.jumpParam == themeId
                : item.jumpUrl == searchString,
          );
        } catch (e) {
          return null; // 表示未找到
        }
      }

      SubFunction? result = findItemOrReturnNull(modulesPayTopList, mark);
      if (result != null) {
        bgImgUrl = result.imgUrl;
      }
    }

    final launchProvider = Provider.of<LaunchProvider>(context, listen: false);
    bool isBlue = launchProvider.launchInfo?.verConfig.halfScreenPage ==
            "/halfScreen-blue"
        ? true
        : false;

    if (ByPackageUtils.isAndroid || ByPackageUtils.isOhos) {
      ByNavigatorUtil.checkLogin(
        context: Get.context!,
        nextStepEvent: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ChangeNotifierProvider(
              create: (_) => PurchaseProvider(
                eventFunction: eventFunction,
                pagePath: pagePath,
                prePagePath: prePagePath,
                isHalfScreen: true,
              ),
              child: PurchaseHalfDialog(
                isBlue: isBlue,
                bgImgUrl: bgImgUrl,
                eventFunction: eventFunction,
                pagePath: pagePath,
                prePagePath: prePagePath,
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ChangeNotifierProvider(
          create: (_) => IosPurchaseProvider(
            eventFunction: eventFunction,
            pagePath: pagePath,
            prePagePath: prePagePath,
            isHalfScreen: true,
          ),
          child: IosPurchaseHalfDialog(
            isBlue: isBlue,
            bgImgUrl: bgImgUrl,
            eventFunction: eventFunction,
            pagePath: pagePath,
            prePagePath: prePagePath,
          ),
        ),
      );
    }
    print("showPayHalfDialog 方法执行完成");
  }

  ///拉取付费页展示支付页页面类型数据(用于归因)
  void getPayStyle({void Function()? onSuccess}) {
    HttpUtils.post(
      APIs.payStyle,
      showMsgWhenFailed: false,
      {},
      success: (data) async {
        byDebugPrint(data, tag: "===PayPage/getPayPageConfig付费页面配置===");
        onSuccess?.call();
        final String landingPage = data['data']['landing_page'];
        if (landingPage.isNotEmpty) {
          launchInfo?.verConfig.landingPage = landingPage;
        }
        // pay_page_id 可能是 int 类型，需要转换为 String
        final payPageIdValue = data['data']['pay_page_id'];
        payPageId = payPageIdValue?.toString() ?? "";
        topOperateMaterialId =
            data['data']['top_operate_material_id']?.toString() ?? "";
      },
    );
  }
}

/// 上报用户设备信息
class DeviceInfoUpload {
  /// 有推送token时加入推送token
  static void uploadUserDeviceInfo({
    String? pushToken,
    bool isFirstIn = true,
  }) async {
    try {
      await ByAscribeUtil.iniBDConvert();
    } catch (e, stackTrace) {
      // Bugly 上报
      FlutterBugly.uploadException(
        message: "归因初始化 $e",
        detail: stackTrace.toString(),
      );
      // 接口上报
      final errorMsg = {
        'type': 'iniBDConvert',
        'error': e.toString(),
        'stack': stackTrace.toString(),
        'push_token': pushToken,
        'is_first_in': isFirstIn,
      };
      LoggerService.sendLog(
        url: '/novel/log/create?security=aohlpsihnt53kasdhflkihn',
        tag: 'iniBDConvert',
        log: jsonEncode(errorMsg),
      );
    }
    final params = await ByDeviceInfoUtils.getUserDiviceInfo();
    byDebugPrint(params, tag: "上报设备信息params===>");
    if (pushToken != null) {
      params["um_device_tokens"] = pushToken;
    }
    HttpUtils.post(
      APIs.deviceInfo,
      params,
      success: (data) {
        Get.log("~~~~~上报设备信息成功$data,$pushToken");
      },
      fail: (code, msg) async {
        FlutterBugly.uploadException(
          message: "上报用户设备信息: $code: $msg",
          detail: msg,
        );
        final errorMsg = {
          'code': code,
          'msg': msg,
          'params': params,
          'network': await ByDeviceInfoUtils.getNetworkStatus(),
        };

        LoggerService.sendLog(
          url: '/novel/log/create?security=aohlpsihnt53kasdhflkihn',
          tag: 'device',
          log: jsonEncode(errorMsg),
        );
        if (isFirstIn) {
          uploadUserDeviceInfo(pushToken: pushToken, isFirstIn: false);
        }
      },
    );
  }
}
