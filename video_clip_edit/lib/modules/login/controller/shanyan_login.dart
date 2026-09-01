/*
 * @Author: duncy
 * @Date: 2026-01-14 18:50:15
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-15 09:18:20
 * @FilePath: /video_clip_edit/lib/modules/login/controller/shanyan_login.dart
 * @Description: 
 */

import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shanyan/shanYanResult.dart';
import 'package:shanyan/shanYanUIConfig.dart';
import 'package:shanyan/shanyan.dart';
import 'package:video_clip_edit/modules/login/beans/login_info_bean.dart';
import 'package:video_clip_edit/providers/login_provider.dart';

import '../../../controller/user_controller.dart';
import '../../../providers/launch_provider.dart';
import '../../../utils/comon/by_navigator_util.dart';
import '../../../utils/comon/by_screen_utils.dart';
import '../../../utils/http/apis.dart';
import '../../../utils/http/http_utils.dart';
import '../../../utils/http/intercept.dart';
import '../../../v2/profile/controllers/home_mine_controller.dart';
import '../../main/beans/launch_info_bean.dart';

class ShanyanLogin {
  static final ShanyanLogin instance = ShanyanLogin._internal();
  ShanyanLogin._internal();
  bool isAudit = Get.context!.read<LaunchProvider>().launchInfo!.isAudit == 1;
  OneKeyLoginManager? oneKeyLoginManager;
  bool _initSDK = true;
  bool _hasInited = false;

  static void initShanYan() {
    OneKeyLoginManager oneKeyLoginManager = OneKeyLoginManager();
    instance.oneKeyLoginManager = oneKeyLoginManager;
    oneKeyLoginManager.init(appId: "fCS7ETTA").then((shanYanResult) {
      if (shanYanResult.code != 1000) {
        instance._initSDK = false;
      }
    });
    oneKeyLoginManager.getPhoneInfo().then((ShanYanResult shanYanResult) {
      ShanYanResult shanYanPhoneInfoResult = shanYanResult;
      if (shanYanPhoneInfoResult.code != 1000) {
        instance._initSDK = false;
      }
    });
    instance._hasInited = true;
  }

  static void login(
      {void Function()? onSuccess,
      void Function()? onFailed,
      void Function(bool)? privacyAction,
      void Function(LoginType)? loginActon,
      void Function()? onNeedBindPhone}) {
    _initOneKeyWidget(
        onSuccess: onSuccess,
        onFailed: () {
          loginActon?.call(LoginType.phone);
        },
        onNeedBindPhone: onNeedBindPhone,
        loginActon: loginActon,
        privacyAction: privacyAction);
  }

  static void _initOneKeyWidget(
      {void Function()? onSuccess,
      void Function()? onFailed,
      void Function(bool)? privacyAction,
      void Function(LoginType)? loginActon,
      void Function()? onNeedBindPhone}) {
    instance.isAudit = getDefaultAgreementChecked();

    print('______审核状态:${instance.isAudit}');
    EasyLoading.show();
    instance.oneKeyLoginManager ??= OneKeyLoginManager();
    OneKeyLoginManager oneKeyLoginManager = instance.oneKeyLoginManager!;
    //"tA75VwxF"
    if (!instance._initSDK || !instance._hasInited) {
      oneKeyLoginManager.init(appId: "fCS7ETTA").then((shanYanResult) {
        print("~~~~~~~~闪验结果：：：code111");
        if (shanYanResult.code != 1000) {
          EasyLoading.dismiss();
          onFailed?.call();
        }
      }).catchError((error) {
        // 闪验初始化异常，切换到验证码登录
        EasyLoading.dismiss();
        onFailed?.call();
        print("闪验初始化异常: $error");
      });
    }

    oneKeyLoginManager.setOneKeyLoginListener((ShanYanResult shanYanResult) {});

    ShanYanUIConfig shanYanUIConfig = ShanYanUIConfig();
    shanYanUIConfig.androidPortrait.isFinish = false;
    shanYanUIConfig.androidPortrait.setFullScreen = false;

    /// 导航栏
    shanYanUIConfig.androidPortrait.setNavReturnImgPath = "login_dialog_close";
    shanYanUIConfig.androidPortrait.setNavReturnBtnWidth = 32;
    shanYanUIConfig.androidPortrait.setNavReturnBtnHeight = 32;
    shanYanUIConfig.androidPortrait.setNavReturnBtnOffsetX = 12;
    // shanYanUIConfig.androidPortrait.setNavTextSize = 16;
    shanYanUIConfig.androidPortrait.setNavText = " ";
    // shanYanUIConfig.androidPortrait.setNavTextBold = true;
    // shanYanUIConfig.androidPortrait.setAuthNavHidden=true;
    shanYanUIConfig.androidPortrait.setAuthBGImgPath = "dengludialog_bj";
    shanYanUIConfig.androidPortrait.setLogoImgPath = "denglulogo";
    shanYanUIConfig.androidPortrait.setLogoWidth = 100;
    shanYanUIConfig.androidPortrait.setLogoHeight = 100;
    shanYanUIConfig.androidPortrait.setLogoOffsetY = 40;
    // shanYanUIConfig.androidPortrait.setLogBtnOffsetY = 400;

    shanYanUIConfig.androidPortrait.setPrivacySmhHidden = false;
    shanYanUIConfig.androidPortrait.setPrivacyWidth = 350;
    shanYanUIConfig.androidPortrait.setPrivacyTextSize = 12;
    shanYanUIConfig.androidPortrait.setPrivacyWidth = 500;
    shanYanUIConfig.androidPortrait.setAppPrivacyColor = ["#222437", "#5B4BF7"];
    shanYanUIConfig.androidPortrait.setPrivacyOffsetX = 24;
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
    shanYanUIConfig.androidPortrait.setPrivacyState = instance.isAudit;

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

    shanYanUIConfig.androidPortrait.setNumFieldOffsetY = 230;
    shanYanUIConfig.androidPortrait.setNumberSize = 32;
    // shanYanUIConfig.androidPortrait.setNumFieldHeight = 24;
    shanYanUIConfig.androidPortrait.setLogBtnTextSize = 16;
    shanYanUIConfig.androidPortrait.setLogBtnWidth = 300;
    // shanYanUIConfig.androidPortrait.setLogBtnOffsetX=30;
    // shanYanUIConfig.androidPortrait.setNumFieldOffsetX=85;
    // shanYanUIConfig.androidPortrait.setLogoOffsetX=135;
    shanYanUIConfig.androidPortrait.setLogBtnOffsetY = 293;
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

    // 添加"其它手机号登录"文本链接，放在登录按钮下方
    ShanYanCustomWidget otherPhoneLoginText = ShanYanCustomWidget(
        "other_phone_login", ShanYanCustomWidgetType.TextView);
    otherPhoneLoginText.textContent = "其它手机号登录";
    otherPhoneLoginText.top = 360; // 放在登录按钮下方
    otherPhoneLoginText.width = 200;
    // 注意：ShanYanCustomWidget不支持直接设置字号，通过调整height来适配16号字体
    // 16号字体通常需要22-24的高度来正常显示
    otherPhoneLoginText.height = 40;
    otherPhoneLoginText.textColor = "#000000";
    otherPhoneLoginText.textFont = 16.0;
    otherPhoneLoginText.isFinish = false;
    otherPhoneLoginText.textAlignment = ShanYanCustomWidgetGravityType.center;
    shanyanCustomWidgetAndroid.add(otherPhoneLoginText);

    // 以下为其他登录方式，暂时隐藏但保留代码以便后续使用
    // logoSlogan
    // ShanYanCustomWidget appSlogan = ShanYanCustomWidget(
    //     "other_custom_button", ShanYanCustomWidgetType.Button);
    // appSlogan.textContent = "其它登录方式";
    // appSlogan.top = 164;
    // appSlogan.width = 263;
    // appSlogan.height = 15;
    // appSlogan.isFinish = false;
    // appSlogan.backgroundImgPath = "login_ai_model";
    // appSlogan.textAlignment = ShanYanCustomWidgetGravityType.center;
    // shanyanCustomWidgetAndroid.add(appSlogan);

    // ShanYanCustomWidget buttonWidgetAndroid = ShanYanCustomWidget(
    //     "other_custom_button", ShanYanCustomWidgetType.TextView);
    // buttonWidgetAndroid.textContent = "其它登录方式";
    // buttonWidgetAndroid.top = 373;
    // buttonWidgetAndroid.width = 180;
    // buttonWidgetAndroid.height = 15;
    // buttonWidgetAndroid.textColor = "#A9A9A9";
    // buttonWidgetAndroid.isFinish = false;
    // buttonWidgetAndroid.textAlignment = ShanYanCustomWidgetGravityType.center;
    // shanyanCustomWidgetAndroid.add(buttonWidgetAndroid);

    // 微信登录按钮 - 隐藏但保留代码
    // ShanYanCustomWidget wechatBtn =
    //     ShanYanCustomWidget("wechat_button", ShanYanCustomWidgetType.TextView);
    // wechatBtn.top = 410;
    // wechatBtn.width = 36;
    // wechatBtn.height = 36;
    // wechatBtn.left = (succWidth / 2.0 - 66).toInt();
    // wechatBtn.isFinish = true;
    // wechatBtn.backgroundImgPath = 'onekey_wx';
    // shanyanCustomWidgetAndroid.add(wechatBtn);

    // 手机号登录按钮 - 隐藏但保留代码
    // ShanYanCustomWidget phoneBtn =
    //     ShanYanCustomWidget("phone_button", ShanYanCustomWidgetType.TextView);
    // phoneBtn.top = 410;
    // phoneBtn.width = 36;
    // phoneBtn.height = 36;
    // phoneBtn.left = (succWidth / 2.0 + 30).toInt();
    // phoneBtn.isFinish = true;
    // phoneBtn.backgroundImgPath = 'onekey_phone';
    // shanyanCustomWidgetAndroid.add(phoneBtn);

    shanYanUIConfig.androidPortrait.widgets = shanyanCustomWidgetAndroid;

    oneKeyLoginManager.addClikWidgetEventListener((eventId) {
      switch (eventId) {
        case "other_phone_login":
          // 点击"其它手机号登录"时切换到手机号登录
          // ByNavigatorUtil.reportDataPoint(
          //   pageTag: "login_page",
          //   operateType: "view",
          //   funcDetailTag: "2",
          //   funcDetailImg: "",
          // );
          loginActon?.call(LoginType.phone);
          oneKeyLoginManager.finishAuthControllerCompletion();
          break;
        case "other_custom_button":
          break;
        case "wechat_button":
          // setLoginSuccess(provider);
          // provider.clickWechatLogin();
          ByNavigatorUtil.reportDataPoint(
            pageTag: "login_page",
            operateType: "view",
            funcDetailTag: "3",
            funcDetailImg: "",
          );
          loginActon?.call(LoginType.wx);
          break;
        case "phone_button":
          loginActon?.call(LoginType.phone);
          oneKeyLoginManager.finishAuthControllerCompletion();
          // provider.updateLoginType(LoginType.phone);

          break;
      }
    });

    oneKeyLoginManager.setAuthThemeConfig(uiConfig: shanYanUIConfig);

    oneKeyLoginManager
        .setAuthPageActionListener((AuthPageActionEvent authPageActionEvent) {
      ///更新外部隐私协议
      if (authPageActionEvent.type == 2) {
        privacyAction?.call(authPageActionEvent.code == 1);
      }
    });

    if (!instance._initSDK || !instance._hasInited) {
      oneKeyLoginManager.getPhoneInfo().then((ShanYanResult shanYanResult) {
        ShanYanResult shanYanPhoneInfoResult = shanYanResult;
        String? result = shanYanPhoneInfoResult.message;
        var dataJson = json.decode(result!);
        if (shanYanPhoneInfoResult.code == 1000) {
          _startOnKeyLogin(oneKeyLoginManager,
              onSuccess: onSuccess,
              onFailed: onFailed,
              onNeedBindPhone: onNeedBindPhone);
        } else {
          // 闪验获取手机号失败，切换到验证码登录
          EasyLoading.dismiss();
          onFailed?.call();
          print(
              "闪验获取手机号失败，code: ${shanYanPhoneInfoResult.code}, message: $dataJson");
        }
      }).catchError((error) {
        // 闪验获取手机号异常，切换到验证码登录
        EasyLoading.dismiss();
        onFailed?.call();
        print("闪验获取手机号异常: $error");
      });
    }
    print('______${instance._hasInited},,,${instance._initSDK}');
    if (instance._initSDK && instance._hasInited) {
      _startOnKeyLogin(oneKeyLoginManager,
          onSuccess: onSuccess,
          onFailed: onFailed,
          onNeedBindPhone: onNeedBindPhone);
    }
  }

  static void _startOnKeyLogin(
    OneKeyLoginManager oneKeyLoginManager, {
    void Function()? onSuccess,
    void Function()? onFailed,
    void Function()? onNeedBindPhone,
  }) {
    oneKeyLoginManager.openLoginAuth().then((data) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "login_page",
        operateType: "view",
        funcDetailTag: "1",
        funcDetailImg: "",
      );
      EasyLoading.dismiss();
      if (1000 != data.code) {
        onFailed?.call();
      }
      oneKeyLoginManager.setOneKeyLoginListener((data) {
        print('闪验______data: ${data.code}');
        ByNavigatorUtil.reportDataPoint(
          pageTag: "login_page_one_click_btn",
          operateType: "click",
          funcDetailTag: "1",
          funcDetailImg: "",
        );
        if (1000 == data.code) {
          oneclickv2(data.token.toString(),
              onFailed: onFailed,
              onSuccess: onSuccess,
              onNeedBindPhone: onNeedBindPhone);
        } else if (1011 == data.code) {
          ///点击返回/取消 （强制自动销毁）
          oneKeyLoginManager.finishAuthControllerCompletion();
        } else {
          ///一键登录获取token失败，回退到验证码登录
          oneKeyLoginManager.finishAuthControllerCompletion();
          EasyLoading.dismiss();
          onFailed?.call();
        }
      });
    }).catchError((error) {
      ///一键登录拉起异常，回退到验证码登录
      EasyLoading.dismiss();
      onFailed?.call();
    });
  }

  /// 一键登录
  static void oneclickv2(
    String smsToken, {
    void Function()? onSuccess,
    void Function()? onFailed,
    void Function()? onNeedBindPhone,
  }) {
    EasyLoading.show();
    HttpUtils.post(
      APIs.oneclickv2,
      {
        "sms_token": smsToken,
      },
      success: (data) async {
        await _handleLoginResponse(data,
            onSuccess: onSuccess,
            onFailed: onFailed,
            onNeedBindPhone: onNeedBindPhone);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        FlutterBugly.uploadException(message: "一键登录", detail: msg);

        ///一键登录API调用失败，回退到验证码登录
        EasyLoading.dismiss();
        // 关闭闪验页面
        instance.oneKeyLoginManager?.finishAuthControllerCompletion();

        // 根据错误码判断是否需要绑定手机号
        // code 参数来自 HttpUtils，类型是 int
        print(
            '一键登录失败，错误码: $code (类型: ${code.runtimeType}), 需要绑定手机号的错误码列表: $needBindPhoneErrorCodes');

        if (needBindPhoneErrorCodes.contains(code) && onNeedBindPhone != null) {
          // 需要绑定手机号
          print('错误码 $code 匹配，跳转到绑定手机号页面');
          onNeedBindPhone.call();
        } else {
          // 回退到验证码登录
          print('错误码 $code 不匹配或 onNeedBindPhone 为 null，回退到手机号验证码登录页面');
          onFailed?.call();
        }
      },
    );
  }

  /// 判断是否需要绑定手机号的错误码列表
  /// 当一键登录返回这些错误码时，会跳转到绑定手机号页面而不是手机号验证码登录页面
  /// 可以根据实际业务需求修改这个列表，添加需要绑定手机号的错误码
  static const List<int> needBindPhoneErrorCodes = [
    -10080, // 需要绑定手机号
  ];

  static Future<void> _handleLoginResponse(data,
      {void Function()? onSuccess,
      void Function()? onFailed,
      void Function()? onNeedBindPhone}) async {
    // 如果状态码不是200，说明登录失败
    if (data["status"] != 200) {
      EasyLoading.dismiss();
      // 关闭闪验页面
      instance.oneKeyLoginManager?.finishAuthControllerCompletion();
      // 显示错误信息
      String errorMsg = data["message"] ?? "登录失败，请重试";
      BotToast.showText(text: errorMsg);
      // 上报错误到Bugly
      FlutterBugly.uploadException(
        message: "一键登录失败",
        detail: "status: ${data["status"]}, message: $errorMsg",
      );

      // 根据错误码判断是否需要绑定手机号
      int? errorCode = data["status"] ?? data["code"];
      print(
          '一键登录响应失败，错误码: $errorCode, 需要绑定手机号的错误码列表: $needBindPhoneErrorCodes');

      if (errorCode != null &&
          needBindPhoneErrorCodes.contains(errorCode) &&
          onNeedBindPhone != null) {
        // 需要绑定手机号
        print('跳转到绑定手机号页面');
        onNeedBindPhone.call();
      } else {
        // 回退到验证码登录
        print('回退到手机号验证码登录页面');
        onFailed?.call();
      }
      return;
    }

    BotToast.showText(text: '登录成功');

    final LoginInfoBean userInfo = LoginInfoBean.fromJson(data["data"]);
    userInfo.isFormal = 1;

    final launchProvider = Get.context!.read<LaunchProvider>();
    LaunchInfoBean? launchInfo = launchProvider.launchInfo;
    launchInfo?.userId = userInfo.userId;
    launchInfo?.isVip = userInfo.isVip;
    launchInfo?.token = userInfo.token;
    launchInfo?.isFormal = userInfo.isFormal ?? 1;
    launchInfo?.canBoundCode = userInfo.canBoundCode;
    launchProvider.notifyListeners();
    // _clearPhoneAndPwd();

    setToken(userInfo.token)?.then((onValue) async {
      if (onValue) {
        // 先更新用户信息，确保用户信息已更新
        await Get.find<UserController>().reloadUserInfo(
          successAction: (userInfo) {
            instance.oneKeyLoginManager?.finishAuthControllerCompletion();
            EasyLoading.dismiss();
            onSuccess?.call();
          },
        );
        bool isHomeMineController = Get.isRegistered<HomeMineController>();
        if (!isHomeMineController) {
          Get.put(HomeMineController(), permanent: true);
        }
        Get.find<HomeMineController>().getDataFromServer();
      }
    });
  }

  /// 获取协议默认勾选状态
  /// 1. 审核状态（isAudit==1）：默认不勾选
  /// 2. 非审核状态（isAudit==0）：
  ///    - isNewAttributionUser==1：默认勾选
  ///    - isNewAttributionUser==0 或 null：默认不勾选
  static bool getDefaultAgreementChecked() {
    // 审核状态：默认不勾选
    bool isAudit = Get.context!.read<LaunchProvider>().launchInfo!.isAudit == 1;
    if (isAudit) {
      return false;
    }

    // 非审核状态：根据 isNewAttributionUser 判断
    try {
      if (Get.isRegistered<UserController>()) {
        final userInfo = Get.find<UserController>().user.value;
        final isNewAttributionUser = userInfo?.isNewAttributionUser ?? 0;
        // isNewAttributionUser==1：默认勾选
        return isNewAttributionUser == 1;
      }
    } catch (e) {
      // 如果获取失败，默认不勾选
    }

    // 默认不勾选
    return false;
  }
}
