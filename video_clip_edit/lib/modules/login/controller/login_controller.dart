/*
 * @Author: cold-x
 * @Date: 2025-05-23 09:48:59
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2025-12-30 13:55:47
 * @FilePath: /video_clip_edit/lib/modules/login/controller/login_controller.dart
 * @Description: 
 */

// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:shanyan/shanYanResult.dart';
import 'package:shanyan/shanYanUIConfig.dart';
import 'package:shanyan/shanyan.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:wechat_kit/wechat_kit.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/intercept.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_device_info_utils.dart';
import 'package:video_clip_edit/modules/login/beans/login_info_bean.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';

import '../../../utils/comon/by_screen_utils.dart';
import '../../../v2/profile/controllers/home_mine_controller.dart';

enum LoginType { oneKey, phone, wx }

class LoginController extends GetxController {
  /// 是否勾选了用户协议
  Rx<bool> agreementChecked = true.obs;

  /// 登录方式，默认为一键登录
  Rx<LoginType> loginType = LoginType.wx.obs;

  /// 用来记录上次的页面
  List<LoginType> pages = [];

  /// 是否允许点击登陆按钮
  Rx<bool> loginEnbled = false.obs;

  /// 手机号
  String? phoneNO;

  /// 验证码
  String? vCode;

  /// 是否允许点击验证码按钮
  Rx<bool> vCodeBtnEnabled = false.obs;

  ///是否只允许手机登录
  bool? onlyPhone = false;

  ///是否一键登录拿到电话信息
  Rx<bool> oneKeyGetPhone = true.obs;

  Function? loginSuccess;

  ///更新登录方式
  updateLoginType(
    LoginType type, {
    bool addToPages = true,
  }) {
    loginType.value = type;
    if (type == LoginType.oneKey) {
      pages = [LoginType.oneKey];
    } else if (addToPages) {
      pages.add(type);
    }
  }

  ///更改验证手机号
  changePhoneNO(String phone) {
    phoneNO = phone;
    vCodeBtnEnabled.value = checkVCodeBtnEnabled();
    loginEnbled.value = checkLoginBtnEnabled();
  }

  ///更改验证验证码
  changeVCode(String code) {
    vCode = code;
    loginEnbled.value = checkLoginBtnEnabled();
  }

  /// 检查登录按钮是否可用
  checkLoginBtnEnabled() =>
      phoneNO != null &&
      vCode != null &&
      phoneNO!.length == 11 &&
      vCode!.length == 4;

  /// 检查验证码按钮是否可用
  checkVCodeBtnEnabled() => phoneNO != null && phoneNO!.length == 11;

  /// 更新用户协议勾选状态
  agreementCheckedStatusChanged(bool checked) {
    agreementChecked.value = checked;
  }

  /// 订阅微信登陆响应
  StreamSubscription<WechatResp>? _respSubs;
  WechatAuthResp? authResp;

  /// 订阅微信登陆
  void subscribeWXLoginResp(BuildContext context) {
    if (!Platform.isAndroid) return;
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

  /// 微信登陆
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
        FlutterBugly.uploadException(message: "微信登录", detail: msg);
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
        oneKeyGetPhone.value = false;
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

    LaunchInfoBean? launchInfo = context.read<LaunchProvider>().launchInfo;
    launchInfo?.userId = userInfo.userId;
    launchInfo?.isVip = userInfo.isVip;
    launchInfo?.token = userInfo.token;
    launchInfo?.isFormal = userInfo.isFormal ?? 1;
    launchInfo?.canBoundCode = userInfo.canBoundCode;

    // _clearPhoneAndPwd();

    setToken(userInfo.token)?.then((onValue) {
      if (onValue) {
        Get.find<UserController>().reloadUserInfo();

        if (loginSuccess != null) {
          loginSuccess!();
          loginSuccess = null;
        } else {
          bool isMainController = Get.isRegistered<MainController>();
          bool isHomeMineController = Get.isRegistered<HomeMineController>();

          if (!isMainController) {
            Get.put(MainController(), permanent: true);
          }
          if (!isHomeMineController) {
            Get.put(HomeMineController(), permanent: true);
          }
          Get.find<HomeMineController>().getDataFromServer();
          Get.find<MainController>().backToMain();
        }
      }
    });
  }

  /// 清除手机号和验证码
  void _clearPhoneAndPwd() {
    phoneNO = "";
    vCode = "";
  }

  ///成功登录更新用户信息
  void setLoginSuccess() {
    loginSuccess = () async {
      await Get.find<UserController>().reloadUserInfo(goBack: () {
        closeOneKeyLogin();
      });

      // if (widget.isPlay) {
      //   /// 继续创建订单
      //   purchaseProvider.createOrder(
      //     onSuccess: (payOrderBean) {},
      //     context: context,
      //   );
      // }
    };
  }

  late OneKeyLoginManager oneKeyLoginManager;
  var oneKeyLoginnumberPhone = "";
  late ShanYanUIConfig shanYanUIConfig;

  ///初始化闪验一键登录
  initOneKeyWidget() {
    // 如果一键登录不可用，直接切换到手机号登录
    if (!oneKeyGetPhone.value) {
      if (loginType.value == LoginType.oneKey) {
        updateLoginType(LoginType.phone);
      }
      return;
    }
    EasyLoading.show();
    oneKeyLoginManager = OneKeyLoginManager();
    //"tA75VwxF"
    print("~~~~~~~~闪验____");
    oneKeyLoginManager.init(appId: "fCS7ETTA").then((shanYanResult) {
      final code = shanYanResult.code;
      final result = shanYanResult.message;
      final content = shanYanResult.toJson().toString();

      print("~~~~~~~~闪验：：：code:$code,,content:$content,,result: $result");
      if (code != 1000) {
        EasyLoading.dismiss();
        oneKeyGetPhone.value = false;
        // 闪验初始化失败，切换到验证码登录
        updateLoginType(LoginType.phone);
      }
    }).catchError((error) {
      // 闪验初始化异常，切换到验证码登录
      EasyLoading.dismiss();
      oneKeyGetPhone.value = false;
      updateLoginType(LoginType.phone);
      print("闪验初始化异常: $error");
    });

    oneKeyLoginManager.setOneKeyLoginListener((ShanYanResult shanYanResult) {
      byDebugPrint(shanYanResult, tag: "XXXXXXX点击：");
    });

    shanYanUIConfig = ShanYanUIConfig();
    shanYanUIConfig.androidPortrait.isFinish = false;
    shanYanUIConfig.androidPortrait.setFullScreen = true;

    /// 导航栏
    shanYanUIConfig.androidPortrait.setStatusBarHidden = false;
    shanYanUIConfig.androidPortrait.setNavReturnImgPath = "login_dialog_close";
    shanYanUIConfig.androidPortrait.setNavReturnBtnWidth = 30;
    shanYanUIConfig.androidPortrait.setNavReturnBtnHeight = 30;
    // shanYanUIConfig.androidPortrait.setAuthBGImgPath = "dengludialog_bj";
    shanYanUIConfig.androidPortrait.setLogoImgPath = "denglulogo";
    shanYanUIConfig.androidPortrait.setLogoWidth = 100;
    shanYanUIConfig.androidPortrait.setLogoHeight = 100;
    shanYanUIConfig.androidPortrait.setLogoOffsetY = 25;
    // shanYanUIConfig.androidPortrait.setLogBtnOffsetY = 400;

    shanYanUIConfig.androidPortrait.setPrivacySmhHidden = false;
    shanYanUIConfig.androidPortrait.setPrivacyWidth = 350;
    shanYanUIConfig.androidPortrait.setPrivacyTextSize = 12;
    shanYanUIConfig.androidPortrait.setPrivacyWidth = 500;
    shanYanUIConfig.androidPortrait.setAppPrivacyColor = ["#222437", "#5B4BF7"];
    shanYanUIConfig.androidPortrait.setPrivacyOffsetGravityLeft = true;

    shanYanUIConfig.androidPortrait.setUncheckedImgPath = "onekey_unckecked";
    shanYanUIConfig.androidPortrait.setCheckedImgPath = "checked";

    shanYanUIConfig.androidPortrait.setCheckBoxWH = [14, 14];

    shanYanUIConfig.androidPortrait.setAppPrivacyOne = [
      "用户协议",
      Get.context!.read<LaunchProvider>().launchInfo?.config.protocol ?? ""
    ];
    shanYanUIConfig.androidPortrait.setAppPrivacyTwo = [
      "隐私政策",
      Get.context!.read<LaunchProvider>().launchInfo?.config.privacy ?? ""
    ];

    /// 是否勾选协议
    shanYanUIConfig.androidPortrait.setPrivacyState = !agreementChecked.value;

    // shanYanUIConfig.androidPortrait.setPrivacyOffsetBottomY=-20;
    shanYanUIConfig.androidPortrait.setPrivacyText = ["我已阅读并同意", "、", "、"];
    int succWidth = ByScreenUtils.screenWidth.toInt();
    int succHeight = ByScreenUtils.screenHeight.toInt();
    shanYanUIConfig.androidPortrait.setDialogTheme = [
      // "400",
      succWidth.toString(),
      // window.physicalSize.width.toString(),
      // double.infinity.toString(),
      succHeight.toString(),
      "0",
      "0",
      "true"
    ];

    shanYanUIConfig.androidPortrait.setNumFieldOffsetBottomY = 265;
    shanYanUIConfig.androidPortrait.setNumberSize = 35;
    shanYanUIConfig.androidPortrait.setLogBtnTextSize = 16;
    shanYanUIConfig.androidPortrait.setLogBtnWidth = 300;
    // shanYanUIConfig.androidPortrait.setLogBtnOffsetX=30;
    // shanYanUIConfig.androidPortrait.setNumFieldOffsetX=85;
    // shanYanUIConfig.androidPortrait.setNavTextSize = 16;
    shanYanUIConfig.androidPortrait.setNavText = "";
    // shanYanUIConfig.androidPortrait.setNavTextBold = true;
    // shanYanUIConfig.androidPortrait.setAuthNavHidden=true;
    // shanYanUIConfig.androidPortrait.setLogoOffsetX=135;
    shanYanUIConfig.androidPortrait.setLogBtnOffsetBottomY = 185;
    shanYanUIConfig.androidPortrait.setLogBtnTextBold = true;
    shanYanUIConfig.androidPortrait.setLogBtnHeight = 50;
    shanYanUIConfig.androidPortrait.setLogBtnTextSize = 16;
    shanYanUIConfig.androidPortrait.setLogBtnBackgroundColor = '#5B4BF7';

    shanYanUIConfig.androidPortrait.setLogoHidden = false;
    shanYanUIConfig.androidPortrait.setSloganHidden = true;
    shanYanUIConfig.androidPortrait.setBackPressedAvailable = true;
    shanYanUIConfig.androidPortrait.setActivityTranslateAnim = [
      "activity_anim_bottom_in",
      "activity_anim_bottom_out"
    ];

    //自定义按钮
    List<ShanYanCustomWidget> shanyanCustomWidgetAndroid = [];
    ShanYanCustomWidget buttonWidgetAndroid = ShanYanCustomWidget(
        "other_custom_button", ShanYanCustomWidgetType.TextView);
    buttonWidgetAndroid.textContent = "其它登录方式";
    buttonWidgetAndroid.bottom = 154;
    buttonWidgetAndroid.width = 180;
    buttonWidgetAndroid.height = 15;
    buttonWidgetAndroid.textColor = "#A9A9A9";
    buttonWidgetAndroid.isFinish = true;
    buttonWidgetAndroid.textAlignment = ShanYanCustomWidgetGravityType.center;
    shanyanCustomWidgetAndroid.add(buttonWidgetAndroid);

    //微信登录
    ShanYanCustomWidget wechatBtn =
        ShanYanCustomWidget("wechat_button", ShanYanCustomWidgetType.TextView);
    wechatBtn.bottom = 90;
    wechatBtn.width = 36;
    wechatBtn.height = 36;
    wechatBtn.left = (succWidth / 2.0 - 66).toInt();
    wechatBtn.isFinish = true;
    wechatBtn.backgroundImgPath = 'onekey_wx';
    shanyanCustomWidgetAndroid.add(wechatBtn);

    //手机号登录
    ShanYanCustomWidget phoneBtn =
        ShanYanCustomWidget("phone_button", ShanYanCustomWidgetType.TextView);
    phoneBtn.bottom = 90;
    phoneBtn.width = 36;
    phoneBtn.height = 36;
    phoneBtn.left = (succWidth / 2.0 + 30).toInt();
    phoneBtn.isFinish = true;
    phoneBtn.backgroundImgPath = 'onekey_phone';
    shanyanCustomWidgetAndroid.add(phoneBtn);

    shanYanUIConfig.androidPortrait.widgets = shanyanCustomWidgetAndroid;

    oneKeyLoginManager.addClikWidgetEventListener((eventId) {
      switch (eventId) {
        case "other_custom_button":
          break;
        case "wechat_button":
          print("~~~~~点击微信登录");
          updateLoginType(LoginType.wx);
          break;
        case "phone_button":
          print("~~~~~点击手机登录");
          updateLoginType(LoginType.phone);
          break;
      }
    });

    oneKeyLoginManager.setAuthThemeConfig(uiConfig: shanYanUIConfig);

    oneKeyLoginManager
        .setAuthPageActionListener((AuthPageActionEvent authPageActionEvent) {
      // final eType = authPageActionEvent.type;
      // final eCode = authPageActionEvent.code;
      // final showPrivayDialog = eType == 3 && eCode == 0;
    });

    oneKeyLoginManager.getPhoneInfo().then((ShanYanResult shanYanResult) {
      ShanYanResult shanYanPhoneInfoResult = shanYanResult;
      String? result = shanYanPhoneInfoResult.message;
      var dataJson = json.decode(result!);
      EasyLoading.dismiss();
      print("~~~~~~~~闪验结果：：：code:$dataJson");
      if (shanYanPhoneInfoResult.code == 1000) {
        oneKeyLoginnumberPhone = dataJson["number"];
        updateLoginType(LoginType.oneKey);
        _startOnKeyLogin();
        // provider.notifyListeners();
      } else {
        // if (shanYanPhoneInfoResult.message != null) {
        //   msg = dataJson["message"];
        // }
        // BotToast.showText(text: msg);
        oneKeyGetPhone.value = false;
        updateLoginType(LoginType.phone);
        print(
            "闪验获取手机号失败，code: ${shanYanPhoneInfoResult.code}, message: $dataJson");
      }
    }).catchError((error) {
      // 闪验获取手机号异常，切换到验证码登录
      EasyLoading.dismiss();
      oneKeyGetPhone.value = false;
      updateLoginType(LoginType.phone);
      print("闪验获取手机号异常: $error");
    });
  }

  _startOnKeyLogin() {
    oneKeyLoginManager.openLoginAuth().then((data) {
      if (1000 != data.code) {
        ///一键登录拉起失败，回退到验证码登录
        EasyLoading.dismiss();
        oneKeyGetPhone.value = false;
        updateLoginType(LoginType.phone);
        return;
      }
      oneKeyLoginManager.setOneKeyLoginListener((data) {
        if (1000 == data.code) {
          oneKeyLoginManager.finishAuthControllerCompletion();
          setLoginSuccess();
          oneclickv2(data.token.toString(), Get.context!);
          // ///一键登录获取token成功
          // ByNavRouterUtils.goBack(context);
        } else if (1011 == data.code) {
          ///点击返回/取消 （强制自动销毁）
          closeOneKeyLogin();
        } else {
          ///一键登录获取token失败，回退到验证码登录
          oneKeyLoginManager.finishAuthControllerCompletion();
          EasyLoading.dismiss();
          oneKeyGetPhone.value = false;
          updateLoginType(LoginType.phone);
        }
      });
    }).catchError((error) {
      ///一键登录拉起异常，回退到验证码登录
      EasyLoading.dismiss();
      oneKeyGetPhone.value = false;
      updateLoginType(LoginType.phone);
    });
  }

  ///一键登录授权页关闭
  void closeOneKeyLogin() {
    EasyLoading.dismiss();
    Get.back();
  }
}
