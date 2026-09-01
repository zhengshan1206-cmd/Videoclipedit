// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:wechat_kit/wechat_kit.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_device_info_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/modules/login/beans/login_info_bean.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';

import '../modules/login/widgets/login_agreement_view.dart';
import '../v2/profile/controllers/home_mine_controller.dart';

enum LoginType { oneKey, phone, wx }

class LoginProvider extends BaseProvider {
  /// 是否勾选了用户协议
  bool agreementChecked = false;

  ///是否一键登录拿到电话信息
  bool oneKeyGetPhone = true;

  /// 登录方式，默认为一键登录
  LoginType loginType = LoginType.wx;
  updateLoginType(
    LoginType type, {
    bool addToPages = true,
  }) {
    loginType = type;
    if (type == LoginType.oneKey) {
      pages = [LoginType.oneKey];
    } else if (addToPages) {
      pages.add(type);
    }
    notifyListeners();
  }

  /// 用来记录上次的页面
  List<LoginType> pages = [];

  /// 是否允许点击登陆按钮
  bool loginEnbled = false;

  // bool oneKeyloginEnbled = true;
  String? phoneNO;
  String? vCode;

  /// 是否允许点击验证码按钮
  bool vCodeBtnEnabled = false;

  Function? loginSuccess;

  // updOneKeyloginEnbled(bool oneKeyloginEnbled){
  //   this.oneKeyloginEnbled=loginType;
  //   notifyListeners();
  // }

  deviceInfo() {
    // ByDeviceUtils.getPackageInfo();
  }

  changePhoneNO(String phone) {
    phoneNO = phone;
    vCodeBtnEnabled = checkVCodeBtnEnabled();
    loginEnbled = checkLoginBtnEnabled();
    notifyListeners();
  }

  changeVCode(String code) {
    vCode = code;
    loginEnbled = checkLoginBtnEnabled();
    notifyListeners();
  }

  checkLoginBtnEnabled() =>
      phoneNO != null &&
      vCode != null &&
      phoneNO!.length == 11 &&
      vCode!.length == 4;

  checkVCodeBtnEnabled() => phoneNO != null && phoneNO!.length == 11;

  agreementCheckedStatusChanged(bool checked) {
    agreementChecked = checked;
    notifyListeners();
  }

  // String? oaid;

  loadOAID() async {
    // final Supplier supplier = await Oaid.instance.getOaid();
    // final String oaidStr = const JsonEncoder.withIndent('  ').convert(supplier);
    // oaid = oaidStr;
    notifyListeners();
  }

  ///点击wx登录
  void clickWechatLogin() {
    if (!agreementChecked) {
      showDialog(
        context: Get.context!,
        builder: (context) {
          return LoginAgreementView(
            callback: () {
              context.read<LoginProvider>().wxLogin();
            },
          );
        },
      );
      return;
    }
    wxLogin();
  }

  StreamSubscription<WechatResp>? _respSubs;
  WechatAuthResp? authResp;

  /// 订阅微信登陆（Android / 鸿蒙）
  void subscribeWXLoginResp(BuildContext context) {
    if (!ByPackageUtils.isAndroid && !ByPackageUtils.isOhos) return;
    cancelSubscribeWXLoginResp();
    _respSubs = WechatKitPlatform.instance.respStream().listen((resp) {
      if (resp is WechatAuthResp) {
        authResp = resp;
        byDebugPrint("response: ${resp.toJson()}");

        /// 微信登陆成，则调用服务器的微信登陆接口
        if (resp.isSuccessful) {
          _loginByWX(context);
        } else {
          EasyLoading.dismiss();
        }
      } else if (resp is WechatPayResp) {
        EasyLoading.dismiss();
      }
    });
  }

  /// 取消订阅微信登陆
  void cancelSubscribeWXLoginResp() {
    _respSubs?.cancel();
    _respSubs = null;
  }

  wxLogin() async {
    final isInstalled = await WechatKitPlatform.instance.isInstalled();
    if (!isInstalled) {
      BotToast.showText(text: "请先安装微信");
      return;
    }

    EasyLoading.show();

    await WechatKitPlatform.instance.auth(
      scope: <String>[WechatScope.kSNSApiUserInfo],
      state: "auth",
    );
    EasyLoading.dismiss();
  }

  /// 微信登陆
  _loginByWX(BuildContext context) {
    final code = authResp?.code ?? "";
    if (code.isEmpty) {
      BotToast.showText(text: "微信登陆失败，请稍后再试");
      EasyLoading.dismiss();
      return;
    }
    HttpUtils.post(
      APIs.loginByWX,
      {
        "code": code,
      },
      success: (data) async {
        byDebugPrint("${data['data']}", tag: "WX登陆:");
        await _handleLoginResponse(data, context);
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 手机号登陆
  void getVCode({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) async {
    final imei = await ByDeviceInfoUtils.deviceInfo();
    HttpUtils.post(
      APIs.sendVCode,
      {
        "phone": phoneNO,
        "uuid": imei.item2,
      },
      success: (data) {
        BotToast.showText(text: data["message"]);
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  /// 一键登录
  oneclickv2(String smsToken, BuildContext context) {
    HttpUtils.post(
      APIs.oneclickv2,
      {
        "sms_token": smsToken,
      },
      success: (data) async {
        await _handleLoginResponse(data, context);
      },
      fail: (code, msg) {
        FlutterBugly.uploadException(message: "一键登录", detail: msg);

        ///一键登录API调用失败，回退到验证码登录
        EasyLoading.dismiss();
        oneKeyGetPhone = false;
        updateLoginType(LoginType.phone);
      },
    );
  }

  void loginWithVCode(BuildContext context) async {
    EasyLoading.show();

    final imei = await ByDeviceInfoUtils.deviceInfo();

    HttpUtils.post(
      APIs.loginByPhone,
      {
        "phone": phoneNO,
        "code": vCode,
        "uuid": imei.item2,
      },
      success: (data) async {
        await _handleLoginResponse(data, context);
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  Future<void> _handleLoginResponse(data, BuildContext context) async {
    ByCommonUtils.debugPrintObj("$data", tag: "sendMsg:----");
    BotToast.showText(text: '登录成功');
    EasyLoading.dismiss();

    if (data["status"] != 200) return;

    final LoginInfoBean userInfo = LoginInfoBean.fromJson(data["data"]);
    userInfo.isFormal = 1;

    final launchProvider = context.read<LaunchProvider>();
    LaunchInfoBean? launchInfo = launchProvider.launchInfo;
    launchInfo?.userId = userInfo.userId;
    launchInfo?.isVip = userInfo.isVip;
    launchInfo?.token = userInfo.token;
    launchInfo?.isFormal = userInfo.isFormal ?? 1;
    launchInfo?.canBoundCode = userInfo.canBoundCode;
    // 通知 LaunchProvider 的监听者，确保视图更新
    launchProvider.notifyListeners();

    // _clearPhoneAndPwd();

    setToken(userInfo.token)?.then((onValue) async {
      if (onValue) {
        // 先更新用户信息，确保用户信息已更新
        await Get.find<UserController>().reloadUserInfo(
          successAction: (userInfo) {
            loginSuccess?.call();
            loginSuccess = null;
          },
        );

        bool isHomeMineController = Get.isRegistered<HomeMineController>();
        if (!isHomeMineController) {
          Get.put(HomeMineController(), permanent: true);
        }
        Get.find<HomeMineController>().getDataFromServer();
        // }
      }
    });
  }

  void _clearPhoneAndPwd() {
    phoneNO = "";
    vCode = "";
  }
}
