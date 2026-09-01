import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/network/provider/user_provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/widgets/dialog/bind_phone_view.dart';

import '../modules/login/controller/login_manager.dart';
import '../modules/purchase/beans/pre_login_config_bean.dart';
import '../widgets/toast_util.dart';

class UserController extends GetxController {
  Worker? _worker;

  final user = Rx<UserInfoBean?>(null);

  final nickName = ''.obs;

  UserProvider get _userProvider => Get.find<UserProvider>();
  LaunchProvider get _launchProvider => Get.context!.read<LaunchProvider>();
  MainController get _mainController => Get.find<MainController>();
  String app_channel = BuildConfig.instance.channelType.channel;

  ///
  bool isNeedBindPhone = true;

  ///支付后跳转链接
  String payJumpUrl = "";

  ///支付后弹窗倒计时
  int payJumpCountdown = 0;

  ///支付后弹窗图片
  String payJumpImage = "";

  ///是否展示推广页引导弹窗
  bool isShowPromotePageGuide = false;

  ///是否展示新人红包页引导弹窗
  bool isShowNewUserRedEnvelope = false;

  ///是否展示手指
  bool isShowFinger = false;

  ///支付挽留弹窗套餐id
  String retentionPackageId = "";

  ///支付挽留弹窗图片
  String retentionPopupImage = "";

  ///是否展示短剧引导手指
  bool isShowShortDramaGuide = false;

  ///短剧引导弹窗图片
  String shortDramaGuideImage = "";

  ///是否展示新春样式（使用 .obs 以便 UI 在接口返回后能响应更新）
  final isShowSpringStyle = false.obs;

  ///新人福利页弹窗图片
  String newUserBenefitsImage = "";

  ///手指
  void showFinger(bool isShow) {
    isShowFinger = isShow;
    update();
  }

  ///展示短剧引导手指
  void showShortDramaGuide(bool isShow) {
    isShowShortDramaGuide = isShow;
    update();
  }

  Future login({
    VoidCallback? cancelLogin,
    VoidCallback? successLogin,

    /// 是否强制使用手机验证码登录（如华为登录页点击“其他登录方式”后切回）
    bool forcePhoneLogin = false,
  }) async {
    ///显示登录页面
    await LoginManager.showLoginPage(
      cancelLogin: cancelLogin,
      useSafeArea: true,
      successLogin: successLogin,
      forcePhoneLogin: forcePhoneLogin,
    ).then((value) async {
      // Get.log("login back~~~~~~ ");
      // await needBindPhoneEvent(showTitle: true, needConfirm: true);
    });
  }

  ///注销账号
  void deleteAccount() {
    showDialog(
      context: Get.context!,
      builder: (c) {
        return CommonDialog(
          title: "注销须知",
          contents:
              "1、账户一旦注销，该账户下的信息、数据、记录将全部删除，且无法恢复。\n2、注销后，账户下的全部权益均被清除:且无法恢复。\n3、注销后，该账户绑定的第三方账户将被解除绑定，您可重新使用并注册成为新用户。\n4、提交注销后将在三个工作日内完成数据清除",
          cancelBtnTitle: "继续注销",
          textAlign: TextAlign.start,
          confirmBtnTitle: "继续使用",
          maxLine: 100,
          reverse: true,
          confirmCallback: () {},
          cancelCallback: () {
            _deleteAccount();
          },
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    HttpUtils.post(
      APIs.accountCancellations,
      {},
      showLoading: true,
      success: (data) {
        BotToast.showText(text: "注销成功");
        _launchProvider.launch(
          Get.context!,
          onSuccess: (p0) {
            /// 更新个人信息
            reloadUserInfo();
            _mainController.tabChanged(0);
            Get.back();
          },
        );
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///退出登陆
  void logout() {
    Get.normalDialog(
      width: Get.width * 0.85,
      title: '温馨提示',
      content: '确定要退出吗？',
      confirmText: '退出',
      confirmAction: () {
        logoutRequest();
      },
    );
  }

  ///退出登录接口请求
  void logoutRequest({
    VoidCallback? onSuccess,
    void Function(int code, String msg)? onFail,
  }) {
    HttpUtils.post(
      APIs.logout,
      {},
      success: (data) async {
        if (data["status"] == 200) {
          _launchProvider.launchInfo = null;

          /// 此处不能直接跳转到 launch 页面（该页面会根据配置跳转到主页或者付费页）
          /// 改为直接调用 游客登陆 接口后，回到个人中心
          _launchProvider.launch(
            Get.context!,
            onSuccess: (LaunchInfoBean bean) {
              /// 更新个人信息
              reloadUserInfo(
                successAction: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.find<NewUserBenefitsController>().checkTime();
                    if (Get.find<NewUserBenefitsController>().showType.value ==
                        1) {
                      Get.find<NewUserBenefitsController>().checkTime();
                    }

                    if (Get.isRegistered<NewUserBenefitsController>()) {
                      Get.find<NewUserBenefitsController>().hideBottom();
                    }
                  });
                },
              );
              Get.back();
              // 执行成功回调
              onSuccess?.call();
            },
          );
        } else {
          // 如果状态码不是200，执行失败回调
          onFail?.call(data["status"] ?? -1, data["message"] ?? "退出登录失败");
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
        // 执行失败回调
        onFail?.call(code, msg);
      },
    );
  }

  ///绑定手机弹窗
  Future<dynamic> showBindPhoneDialog({
    bool? showTitle,
    bool? needConfirm,
    bool? barrierDismissible,
    bool justBindPhone = false,
    VoidCallback? cancelBinding,
  }) async {
    await showDialog(
      context: Get.context!,
      useSafeArea: false,
      barrierDismissible: barrierDismissible ?? false,
      builder: (context) {
        return BindPhoneView(
          showTitle: showTitle ?? false,
          needConfirm: needConfirm ?? false,
          justBindPhone: justBindPhone,
          cancelBinding: cancelBinding,
        );
      },
    );
  }

  ///更新用户信息
  Future reloadUserInfo({
    void Function(UserInfoBean? userInfo)? successAction,
    void Function(int, String)? onFailed,
    VoidCallback? goBack,
  }) async {
    await _userProvider.getUserInfo(
      onSuccess: (userInfo) {
        saveUser(userInfo);
        // Get.log("保存用户数据===>${userInfo?.toJson()}");

        if (goBack != null) {
          goBack();
        }
        if (successAction != null) {
          successAction(userInfo);
        }
      },
      onFailed: onFailed,
    );
  }

  void saveUser(UserInfoBean? userInfo) {
    user.value = userInfo;
  }

  String _fixedNickname(String? nickname) =>
      (nickname != null && nickname.isNotEmpty) ? nickname : '';

  @override
  void onInit() {
    super.onInit();
    _worker = ever(user, (user) {
      nickName.value = _fixedNickname(user?.nickName);
      update();
    });
    nickName.value = _fixedNickname(user.value?.nickName);
  }

  @override
  void onReady() {
    // checkNeedPhoneBind();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _worker?.dispose();
  }

  /// 要不要开启强制绑定手机号
  checkNeedPhoneBind({void Function()? onSuccess}) async {
    HttpUtils.get(
      APIs.getConfig,
      {"group": "xi_tong_pei_zhi"},
      success: (data) {
        print("获取的强制绑定数据===>");
        byDebugPrint(data, tag: "peizhi11111111111111---11");
        final config = data["data"]["qiang_zhi_bang_ding_shou_ji_hao"];
        if (config != null && config is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(config);
          if (configBean.valText == "1") {
            isNeedBindPhone = true;
          }
        }

        ///支付后弹窗跳转链接
        final payJumpConfig = data["data"]["zhi_fu_hou_tan_chuang_tiao_zhuan"];
        if (payJumpConfig != null && payJumpConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            payJumpConfig,
          );
          payJumpUrl = configBean.valText;
        }

        ///支付后弹窗倒计时
        final payJumpCountdownConfig =
            data["data"]["zhi_fu_hou_tan_chuang_dao_ji_shi"];
        if (payJumpCountdownConfig != null && payJumpCountdownConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            payJumpCountdownConfig,
          );
          payJumpCountdown = int.parse(configBean.valText);
        }

        ///支付后弹窗图片
        final payJumpImageConfig = data["data"]["zhi_fu_hou_tan_chuang_tu"];
        if (payJumpImageConfig != null && payJumpImageConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            payJumpImageConfig,
          );
          payJumpImage = configBean.valText;
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 妙笔配置
  checkMiaoBiConfig({void Function()? onSuccess}) async {
    HttpUtils.get(
      APIs.getConfig,
      {"group": "miao_bi_gong_fang"},
      success: (data) {
        byDebugPrint(data, tag: "miao_bi_gong_fang11111111111111---11");

        ///超级配置新人红包页弹窗开关
        final superConfig =
            data["data"]["new_user_qi_yong_duan_ju_yin_dao_liu_cheng"];
        if (superConfig != null && superConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            superConfig,
          );
          if (configBean.valText == "1") {
            isShowNewUserRedEnvelope = true;
            update();
          }
        }

        // 支付挽留弹窗套餐	zhi_fu_wan_liu_tan_chuang_tao_can
        final retentionPackageConfig =
            data["data"]["zhi_fu_wan_liu_tan_chuang_tao_can"];
        if (retentionPackageConfig != null && retentionPackageConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            retentionPackageConfig,
          );
          retentionPackageId = configBean.valText;
        }
        // 支付挽留弹窗	zhi_fu_wan_liu_tan_chuang
        final retentionPopupImageConfig =
            data["data"]["zhi_fu_wan_liu_tan_chuang"];
        if (retentionPopupImageConfig != null &&
            retentionPopupImageConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            retentionPopupImageConfig,
          );
          retentionPopupImage = configBean.valText;
        }

        ///短剧引导弹窗图片
        final shortDramaGuideImageConfig = data["data"]["0fen_si_cheng_jie_ye"];
        if (shortDramaGuideImageConfig != null &&
            shortDramaGuideImageConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            shortDramaGuideImageConfig,
          );
          shortDramaGuideImage = configBean.valText;
        }

        ///皮肤风格
        final skinStyleConfig = data["data"]["pi_fu_feng_ge"];
        if (skinStyleConfig != null && skinStyleConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            skinStyleConfig,
          );
          isShowSpringStyle.value = configBean.valText == "2";
          update();
        }

        ///新人福利页弹窗图片地址
        final newUserBenefitsImageConfig =
            data["data"]["0__01_yuan_cheng_jie_tu_pian"];
        if (newUserBenefitsImageConfig != null &&
            newUserBenefitsImageConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            newUserBenefitsImageConfig,
          );
          newUserBenefitsImage = configBean.valText;
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///更新支付后弹窗配置
  updatePayJumpConfig(String? url, int? countdown, String? image) {
    payJumpUrl = url ?? "";
    payJumpCountdown = countdown ?? 0;
    payJumpImage = image ?? "";
    update();
  }

  Future needBindPhoneEvent({
    bool? showTitle,
    bool? needConfirm,
    VoidCallback? goNextEvent,
    VoidCallback? cancelBinding,
  }) async {
    Get.log(
      "isNeedBindPhone======>$isNeedBindPhone isBindPhone===>${user.value?.isBindPhone}  ",
    );

    if (isNeedBindPhone) {
      ///未绑定手机号
      if (user.value?.isBindPhone == 0 && ((user.value?.isFormal ?? 0) == 1)) {
        await showBindPhoneDialog(
          showTitle: showTitle,
          needConfirm: needConfirm,
          barrierDismissible: false,
          cancelBinding: cancelBinding,
          justBindPhone: true,
        ).then((value) {
          if (goNextEvent != null) {
            goNextEvent();
          }
        });
      }
    }
  }
}
