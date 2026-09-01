// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shanyan/shanyan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/main.dart';
import 'package:shanyan/shanYanResult.dart';
import 'package:shanyan/shanYanUIConfig.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/login/login_page.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/login_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/login/widgets/count_down_btn.dart';
import 'package:video_clip_edit/modules/login/widgets/login_text_field.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/v2/profile/controllers/home_mine_controller.dart';

class LoginContentView extends StatefulWidget {
  final LoginPageType type;
  //是否自动支付
  bool isPlay;
  final bool? privacy;
  final Function()? successLogin;
  LoginContentView({
    super.key,
    required this.type,
    this.isPlay = true,
    this.privacy,
    this.successLogin,
  });

  @override
  State<LoginContentView> createState() => LoginContentViewState();
}

class LoginContentViewState extends State<LoginContentView> {
  final FocusNode phoneNode = FocusNode();
  final FocusNode codeNode = FocusNode();
  late LoginProvider provider;
  late bool isAudit = true;
  late OneKeyLoginManager oneKeyLoginManager;
  var oneKeyLoginnumberPhone = "";
  late ShanYanUIConfig shanYanUIConfig;
  LoginType? _lastReportedLoginType; // 记录上次上报的登录类型，避免重复上报

  /// 获取登录方式的数字标识：1一键登录 2手机验证码 3微信
  int _getLoginTypeTag(LoginType loginType) {
    switch (loginType) {
      case LoginType.oneKey:
        return 1;
      case LoginType.phone:
        return 2;
      case LoginType.wx:
        return 3;
    }
  }

  oneKeyLogin() {
    _initOneKeyWidget();
  }

  @override
  void initState() {
    super.initState();
    provider = context.read<LoginProvider>();
    isAudit = context.read<LaunchProvider>().launchInfo!.isAudit == 1;
    // 延迟到构建完成后更新状态，避免在构建过程中调用 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.privacy == null) {
        provider.agreementCheckedStatusChanged(_getDefaultAgreementChecked());
      } else {
        provider.agreementCheckedStatusChanged(widget.privacy!);
      }
      print('_______手机号${widget.privacy}');
      // 上报登录页显示埋点
      // _reportLoginPageView();
    });

    provider.subscribeWXLoginResp(context);
  }

  /// 获取协议默认勾选状态
  /// 1. 审核状态（isAudit==1）：默认不勾选
  /// 2. 非审核状态（isAudit==0）：
  ///    - isNewAttributionUser==1：默认勾选
  ///    - isNewAttributionUser==0 或 null：默认不勾选
  bool _getDefaultAgreementChecked() {
    // 审核状态：默认不勾选
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

  /// 上报登录页显示埋点
  void _reportLoginPageView() {
    // 只在登录类型改变时上报，避免重复上报
    if (_lastReportedLoginType != provider.loginType) {
      _lastReportedLoginType = provider.loginType;
      ByNavigatorUtil.reportDataPoint(
        pageTag: "login_page",
        operateType: "view",
        funcDetailTag: _getLoginTypeTag(provider.loginType).toString(),
        funcDetailImg: "",
      );
    }
  }

  initOneKey() {
    try {
      _initOneKeyWidget();
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  _initOneKeyWidget() {
    ///闪验结果获取中时不调用
    if (!provider.oneKeyGetPhone) {
      // 如果一键登录不可用，直接切换到手机号登录，确保显示登录内容
      if (provider.loginType == LoginType.oneKey) {
        provider.updateLoginType(LoginType.phone);
      }
      return;
    }
    EasyLoading.show();
    oneKeyLoginManager = OneKeyLoginManager();
    //"tA75VwxF"
    oneKeyLoginManager
        .init(appId: "fCS7ETTA")
        .then((shanYanResult) {
          setState(() {
            // print("~~~~~~~~闪验：：：code:$_code,,content:$_content,,result: $_result");
            print("~~~~~~~~闪验结果：：：code111");
            if (shanYanResult.code != 1000) {
              EasyLoading.dismiss();
              provider.oneKeyGetPhone = false;
              // 闪验初始化失败，切换到验证码登录
              if (provider.loginType != LoginType.phone) {
                provider.updateLoginType(LoginType.phone);
              }
            }
          });
        })
        .catchError((error) {
          // 闪验初始化异常，切换到验证码登录
          EasyLoading.dismiss();
          provider.oneKeyGetPhone = false;
          if (provider.loginType != LoginType.phone) {
            provider.updateLoginType(LoginType.phone);
          }
          print("闪验初始化异常: $error");
        });

    oneKeyLoginManager.setOneKeyLoginListener((ShanYanResult shanYanResult) {
      byDebugPrint(shanYanResult, tag: "XXXXXXX点击：");
    });

    shanYanUIConfig = ShanYanUIConfig();
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
      context.read<LaunchProvider>().launchInfo?.config.protocol ?? "",
    ];
    shanYanUIConfig.androidPortrait.setAppPrivacyTwo = [
      "隐私政策",
      context.read<LaunchProvider>().launchInfo?.config.privacy ?? "",
    ];

    /// 是否勾选协议
    shanYanUIConfig.androidPortrait.setPrivacyState =
        _getDefaultAgreementChecked();

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
      "true",
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
      "activity_anim_bottom_out",
    ];

    //自定义按钮
    List<ShanYanCustomWidget> shanyanCustomWidgetAndroid = [];

    // 添加"其它手机号登录"文本链接，放在登录按钮下方
    ShanYanCustomWidget otherPhoneLoginText = ShanYanCustomWidget(
      "other_phone_login",
      ShanYanCustomWidgetType.TextView,
    );
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
          provider.updateLoginType(LoginType.phone);
          // 切换登录方式后上报登录页显示埋点
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _reportLoginPageView();
          // });
          oneKeyLoginManager.finishAuthControllerCompletion();
          // ByNavRouterUtils.goBack(context);
          break;
        case "other_custom_button":
          break;
        case "wechat_button":
          // 上报登录按钮点击埋点（微信登录）
          ByNavigatorUtil.reportDataPoint(
            pageTag: "login_page_one_click_btn",
            operateType: "click",
            funcDetailTag: _getLoginTypeTag(LoginType.wx).toString(),
            funcDetailImg: "",
          );
          provider.updateLoginType(LoginType.wx);
          setLoginSuccess(provider);
          provider.clickWechatLogin();
          break;
        case "phone_button":
          provider.updateLoginType(LoginType.phone);
          // 切换登录方式后上报登录页显示埋点
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _reportLoginPageView();
          // });
          break;
      }
    });

    oneKeyLoginManager.setAuthThemeConfig(uiConfig: shanYanUIConfig);

    oneKeyLoginManager.setAuthPageActionListener((
      AuthPageActionEvent authPageActionEvent,
    ) {
      ///更新外部隐私协议
      if (authPageActionEvent.type == 2) {
        provider.agreementCheckedStatusChanged(authPageActionEvent.code == 1);
      }
    });

    oneKeyLoginManager
        .getPhoneInfo()
        .then((ShanYanResult shanYanResult) {
          ShanYanResult shanYanPhoneInfoResult = shanYanResult;
          String? result = shanYanPhoneInfoResult.message;
          var dataJson = json.decode(result!);
          setState(() {
            EasyLoading.dismiss();
            print("~~~~~~~~闪验结果：：：code:$dataJson");
            if (shanYanPhoneInfoResult.code == 1000) {
              oneKeyLoginnumberPhone = dataJson["number"];
              // provider.updateLoginType(LoginType.oneKey);
              provider.oneKeyGetPhone = true;
              _startOnKeyLogin();
              // provider.notifyListeners();
            } else {
              // 闪验获取手机号失败，切换到验证码登录
              provider.oneKeyGetPhone = false;
              if (provider.loginType == LoginType.oneKey) {
                provider.updateLoginType(LoginType.phone);
              }
              print(
                "闪验获取手机号失败，code: ${shanYanPhoneInfoResult.code}, message: $dataJson",
              );
            }
          });
        })
        .catchError((error) {
          // 闪验获取手机号异常，切换到验证码登录
          setState(() {
            EasyLoading.dismiss();
            provider.oneKeyGetPhone = false;
            if (provider.loginType == LoginType.oneKey) {
              provider.updateLoginType(LoginType.phone);
            }
            print("闪验获取手机号异常: $error");
          });
        });
  }

  @override
  void dispose() {
    provider.cancelSubscribeWXLoginResp();
    byDebugPrint("------------dispose");
    if (isAudit) {
      provider.agreementChecked = false;
    }

    super.dispose();
  }

  String mediaQueryWidth = "0";

  Widget loadingWidget() {
    return SizedBox(
      height: 200.h,
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<LoginProvider>();
    mediaQueryWidth = MediaQuery.of(context).size.width.toString();

    // 埋点上报只在点击事件时触发，不在 build 中自动触发

    // 如果是一键登录但一键登录不可用，自动切换到手机号登录
    if (provider.loginType == LoginType.oneKey && !provider.oneKeyGetPhone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (provider.loginType == LoginType.oneKey) {
          provider.updateLoginType(LoginType.phone);
        }
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Offstage(
            // 如果是一键登录但不可用，也显示手机号登录界面
            offstage:
                provider.loginType != LoginType.phone &&
                !(provider.loginType == LoginType.oneKey &&
                    !provider.oneKeyGetPhone),
            child: _buildPhoneCodeWidgetr(),
          ),
          Offstage(
            offstage: provider.loginType != LoginType.wx,
            child: _buildOtherMehods(context),
          ),
          Offstage(
            offstage: provider.loginType != LoginType.phone,
            child: SizedBox(height: 18.w),
          ),
          // Offstage(
          //   offstage: provider.loginType != LoginType.phone,
          //   child: GestureDetector(
          //     onTap: () {
          //       final isAudit =
          //           context.read<LaunchProvider>().launchInfo!.isAudit;
          //       if (isAudit == 1) {
          //         provider.agreementCheckedStatusChanged(false);
          //       }

          //       /// 切换为一键登录
          //       // context.read<LoginProvider>().updateLoginType(LoginType.oneKey);
          //       _initOneKeyWidget();
          //     },
          //     child: Text(
          //       "本机号码一键登录",
          //       style: TextStyle(color: Colors.black, fontSize: 14.sp),
          //     ),
          //   ),
          // ),
          SizedBox(height: 5.w),
          // _weiXinLoginBtn(),
        ],
      ),
    );
  }

  _startOnKeyLogin() {
    oneKeyLoginManager
        .openLoginAuth()
        .then((data) {
          if (1000 == data.code) {
            if (provider.pages.isEmpty ||
                provider.pages.last != LoginType.phone) {
              provider.updateLoginType(LoginType.phone);
            }
          } else {
            ///一键登录拉起失败，回退到验证码登录
            EasyLoading.dismiss();
            provider.oneKeyGetPhone = false;
            provider.updateLoginType(LoginType.phone);
            return;
          }
          oneKeyLoginManager.setOneKeyLoginListener((data) {
            if (1000 == data.code) {
              // 上报一键登录按钮点击埋点
              ByNavigatorUtil.reportDataPoint(
                pageTag: "login_page_one_click_btn",
                operateType: "click",
                funcDetailTag: _getLoginTypeTag(LoginType.oneKey).toString(),
                funcDetailImg: "",
              );
              oneKeyLoginManager.finishAuthControllerCompletion();
              setLoginSuccess(provider);
              provider.oneclickv2(data.token.toString(), context);
              // ///一键登录获取token成功
              // ByNavRouterUtils.goBack(context);
            } else if (1011 == data.code) {
              ///点击返回/取消 （强制自动销毁）
              ByNavRouterUtils.goBack(context);
            } else {
              ///一键登录获取token失败，回退到验证码登录
              oneKeyLoginManager.finishAuthControllerCompletion();
              EasyLoading.dismiss();
              provider.oneKeyGetPhone = false;
              provider.updateLoginType(LoginType.phone);
              // 自动回退不是用户点击触发，不上报埋点
            }
          });
        })
        .catchError((error) {
          ///一键登录拉起异常，回退到验证码登录
          EasyLoading.dismiss();
          provider.oneKeyGetPhone = false;
          provider.updateLoginType(LoginType.phone);
        });
  }

  Widget _weiXinLoginBtn() {
    if (provider.loginType != LoginType.phone) {
      return const SizedBox();
    }
    return Column(
      children: [
        SizedBox(height: 10.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 42.w),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 1,
                  child: ByWidgetsUtil.gradientBgContainer(
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFF101E48).withOpacity(0.05),
                      colorEnd: const Color(0xFF101E48).withOpacity(0.3),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: 10,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              ByWidgetsUtil.commonText(
                text: "其它登录方式",
                textColor: const Color(0xFF101E48).withOpacity(0.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 1,
                  child: ByWidgetsUtil.gradientBgContainer(
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFF101E48).withOpacity(0.05),
                      colorEnd: const Color(0xFF101E48).withOpacity(0.3),
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: 10,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        ByWidgetsUtil.imageBtn(
          image: "assets/login/wei_xin_logo_icon.png",
          width: 36.w,
          height: 36.w,
          imageWidth: 36.w,
          imageHeight: 36.w,
          bgColor: Colors.transparent,
          onClick: () {
            // 上报登录按钮点击埋点（微信登录）
            ByNavigatorUtil.reportDataPoint(
              pageTag: "login_page_one_click_btn",
              operateType: "click",
              funcDetailTag: _getLoginTypeTag(LoginType.wx).toString(),
              funcDetailImg: "",
            );
            setLoginSuccess(provider);
            provider.clickWechatLogin();
            // provider.updateLoginType(LoginType.wx);
          },
        ),
      ],
    );
  }

  ///验证码登录
  Widget _buildPhoneCodeWidgetr() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginTextField(
                hintText: "请输入手机号",
                focusNode: phoneNode,
                maxLength: 11,
                keyboardType: TextInputType.number,
                inputCallBack: (value) {
                  provider.changePhoneNO(value);
                },
              ),
              Offstage(
                offstage:
                    (provider.phoneNO?.length ?? 0) == 11 ||
                    !phoneNode.hasFocus,
                child: SizedBox(height: 3.h),
              ),
              Offstage(
                offstage:
                    (provider.phoneNO?.length ?? 0) == 11 ||
                    !phoneNode.hasFocus,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/mine/icon_info.png",
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 5.w),
                    ByWidgetsUtil.commonText(
                      text: "请输入正确的手机号码",
                      fontSize: 12.sp,
                      textColor: const Color(0xFF5A4BF7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginTextField(
                    // text: provider.vCode,
                    hintText: "请输入验证码",
                    focusNode: codeNode,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    inputCallBack: (value) {
                      provider.changeVCode(value);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 23.w,
              child: CountDownBtn(
                getCodeText: "发送",
                // fontSize: 16.sp,
                resendAfterText: "重新发送",
                showBorder: true,
                onTap: () {
                  // 上报获取验证码按钮点击埋点
                  ByNavigatorUtil.reportDataPoint(
                    pageTag: "login_page_verify_btn",
                    operateType: "click",
                    funcDetailTag: _getLoginTypeTag(
                      provider.loginType,
                    ).toString(),
                    funcDetailImg: "",
                  );
                  if (!provider.agreementChecked) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        // 上报协议弹框显示埋点
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ByNavigatorUtil.reportDataPoint(
                            pageTag: "login_page_protocol_dialog",
                            operateType: "view",
                            funcDetailTag: _getLoginTypeTag(
                              provider.loginType,
                            ).toString(),
                            funcDetailImg: "",
                          );
                        });
                        return LoginAgreementView(
                          btnTitle: "确认同意",
                          isLoginSend: true,
                          callback: () {
                            // 上报协议弹框确认按钮点击埋点
                            ByNavigatorUtil.reportDataPoint(
                              pageTag: "login_page_protocol_yes_btn",
                              operateType: "click",
                              funcDetailTag: _getLoginTypeTag(
                                provider.loginType,
                              ).toString(),
                              funcDetailImg: "",
                            );
                            provider.agreementCheckedStatusChanged(true);
                          },
                          onClose: () {
                            // 上报协议弹框关闭按钮点击埋点
                            ByNavigatorUtil.reportDataPoint(
                              pageTag: "login_page_protocol_no_btn",
                              operateType: "click",
                              funcDetailTag: _getLoginTypeTag(
                                provider.loginType,
                              ).toString(),
                              funcDetailImg: "",
                            );
                          },
                        );
                      },
                    );
                  }
                },
                // getVCode: provider.getVCode,
              ),
            ),
          ],
        ),
        SizedBox(height: 35.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!provider.loginEnbled) return;
              // 上报登录按钮点击埋点
              ByNavigatorUtil.reportDataPoint(
                pageTag: "login_page_one_click_btn",
                operateType: "click",
                funcDetailTag: _getLoginTypeTag(provider.loginType).toString(),
                funcDetailImg: "",
              );
              if (!provider.agreementChecked) {
                showDialog(
                  context: context,
                  builder: (context) {
                    // 上报协议弹框显示埋点
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ByNavigatorUtil.reportDataPoint(
                        pageTag: "login_page_protocol_dialog",
                        operateType: "view",
                        funcDetailTag: _getLoginTypeTag(
                          provider.loginType,
                        ).toString(),
                        funcDetailImg: "",
                      );
                    });
                    return LoginAgreementView(
                      callback: () {
                        // 上报协议弹框确认按钮点击埋点
                        ByNavigatorUtil.reportDataPoint(
                          pageTag: "login_page_protocol_yes_btn",
                          operateType: "click",
                          funcDetailTag: _getLoginTypeTag(
                            provider.loginType,
                          ).toString(),
                          funcDetailImg: "",
                        );
                        if (!provider.loginEnbled) return;
                        _startLogin(provider);
                      },
                      onClose: () {
                        // 上报协议弹框关闭按钮点击埋点
                        ByNavigatorUtil.reportDataPoint(
                          pageTag: "login_page_protocol_no_btn",
                          operateType: "click",
                          funcDetailTag: _getLoginTypeTag(
                            provider.loginType,
                          ).toString(),
                          funcDetailImg: "",
                        );
                      },
                    );
                  },
                );
              } else {
                if (!provider.loginEnbled) return;
                _startLogin(provider);
              }
            },
            child: Container(
              height: 50.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: provider.loginEnbled
                    ? ByColorUtil.TabTextColorSelected
                    : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Text(
                "立即登录",
                style: TextStyle(
                  color: ByColorUtil.WhiteColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startLogin(LoginProvider provider) {
    setLoginSuccess(provider);
    provider.loginWithVCode(navigatorKey.currentState!.context);
  }

  void setLoginSuccess(LoginProvider provider) {
    // 登录成功回调：由 LoginProvider._handleLoginResponse 在 reloadUserInfo 的 successAction 中调用
    // 注意：此时用户信息已更新完毕，无需再次调用 reloadUserInfo
    provider.loginSuccess = () async {
      final BuildContext? ctx = navigatorKey.currentState?.context;
      if (ctx == null) return;
      // 1. 先关闭登录页，再执行下一步，避免先执行下一步再关页导致路由/状态错乱
      ByNavRouterUtils.goBack(ctx);
      // 2. 若有调用方传入的下一步（如 checkLogin 的 nextStepEvent），只执行它，不再强制回首页
      if (widget.successLogin != null) {
        widget.successLogin!();
      } else {
        _executeNextStepAfterLogin();
      }
    };
  }

  /// 执行登录后的下一步操作（与 _handleLoginResponse 中的默认逻辑一致）
  void _executeNextStepAfterLogin() {
    try {
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
    } catch (e) {
      print("执行下一步操作时出错: $e");
    }
  }

  Widget _buildOtherMehods(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 73.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: ByWidgetsUtil.btnWithIcon(
            title: "微信一键登录",
            borderRadius: 12.w,
            contentGap: 10.w,
            iconW: 25.w,
            iconH: 25.w,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            bgColor: const Color(0xFF20BF64),
            iconPath: "assets/login/third_wx.png",
            onClick: () {
              // 上报登录按钮点击埋点（微信登录）
              ByNavigatorUtil.reportDataPoint(
                pageTag: "login_page_one_click_btn",
                operateType: "click",
                funcDetailTag: _getLoginTypeTag(LoginType.wx).toString(),
                funcDetailImg: "",
              );
              setLoginSuccess(provider);
              provider.clickWechatLogin();
            },
          ),
        ),
        SizedBox(height: 25.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 42.w),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 1,
                  child: ByWidgetsUtil.gradientBgContainer(
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFF101E48).withOpacity(0.05),
                      colorEnd: const Color(0xFF101E48).withOpacity(0.3),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: 10,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              ByWidgetsUtil.commonText(
                text: "其它号码登录",
                textColor: const Color(0xFF101E48).withOpacity(0.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 1,
                  child: ByWidgetsUtil.gradientBgContainer(
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFF101E48).withOpacity(0.05),
                      colorEnd: const Color(0xFF101E48).withOpacity(0.3),
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: 10,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        ByWidgetsUtil.imageBtn(
          image: "assets/login/login_method_phone.png",
          width: 48.w,
          height: 48.w,
          imageWidth: 36.w,
          imageHeight: 36.w,
          bgColor: Colors.transparent,
          onClick: () {
            provider.updateLoginType(LoginType.phone);
            // 切换登录方式后上报登录页显示埋点
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   _reportLoginPageView();
            // });
          },
        ),
      ],
    );
  }
}
