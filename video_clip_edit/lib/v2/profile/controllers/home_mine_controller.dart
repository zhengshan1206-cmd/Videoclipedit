import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/data/model/user/user_works_data.dart';
import 'package:video_clip_edit/modules/home/beans/setting_item_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/login_provider.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

import '../../../modules/home/widgets/sub_funcs_view.dart';
import '../../../utils/comon/by_common_utils.dart';
import '../../../widgets/toast_util.dart';

class HomeMineController extends GetxController {
  LaunchProvider get launchProvider => Get.context!.read<LaunchProvider>();

  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  var settingConfis = <SettingItemBean>[];
  RxList<UserWorksData> userWorksList = RxList<UserWorksData>();
  var versionName = ''.obs;

  ///气泡位置
  var bubblePosition = Rx<Offset?>(null);

  ///计算气泡位置
  void calculatePosition(GlobalKey key) {
    // 获取固定按钮的渲染对象
    final RenderBox? fixedButtonRenderBox =
        key.currentContext?.findRenderObject() as RenderBox?;

    if (fixedButtonRenderBox != null) {
      // 获取固定按钮在全局坐标系中的位置
      final fixedButtonPosition =
          fixedButtonRenderBox.localToGlobal(Offset.zero);

      // 计算动态按钮的位置（例如：在固定按钮右侧 20 像素）
      bubblePosition.value = Offset(
          Get.width -
              (fixedButtonPosition.dx + fixedButtonRenderBox.size.width / 2) -
              20.w,
          fixedButtonPosition.dy + fixedButtonRenderBox.size.height + 6.h);
    }
  }

  ///运营配置的banner数据
  List<SubFunction>? menuItemBeans;

  ///是否展示关闭banner按钮
  bool isShowBanner = true;

  @override
  void onReady() {
    super.onReady();
    getDataFromServer();
    _getVersionName();
  }

  void getDataFromServer() {
    _getWorksCount();
    _loadSettingConfig();
    loadMenuData();
  }

  ///获取作品信息
  _getWorksCount() {
    HttpUtils.get(
      APIs.getUserWorks,
      {},
      success: (data) {
        final userWorksData = data["data"];
        if (userWorksData is List) {
          userWorksList.assignAll(
              userWorksData.map((e) => UserWorksData.fromJson(e)).toList());
        }
        update();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///获取设置的相关配置
  _loadSettingConfig() {
    HttpUtils.get(
      APIs.loadSettingIems,
      {},
      success: (data) {
        final settingItems = data["data"];
        if (settingItems is List) {
          settingConfis.assignAll(
              settingItems.map((e) => SettingItemBean.fromJson(e)).toList());
        }
        update();
      },
      fail: (code, msg) {},
    );
  }

  ///复制内容
  void operateCopy(String copyContent) {
    Clipboard.setData(ClipboardData(text: copyContent));
    EasyLoading.showSuccess("复制成功");
  }

  void login() {
    ByNavigatorUtil.checkLogin(context: Get.context!, nextStepEvent: () {});
  }

  void bindPhone() {
    userController.showBindPhoneDialog(showTitle: true);
  }

  _getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionName.value = packageInfo.version;
  }

  ///获取运营配置的banner数据
  loadMenuData() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 7},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        byDebugPrint(bannerData, tag: "我的页面Banner:---");
        List<SubFunction> beans =
            bannerData.map((e) => SubFunction.fromJson(e)).toList();
        menuItemBeans = beans;
        update();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///关闭banner
  closeBannerEvent() {
    isShowBanner = false;
    update();
  }

  ///微信登录检测
  void checkWechatLogin() {
    ByNavigatorUtil.reportDataPoint(
      pageTag: "my_page_wechat_login_btn",
      operateType: "click",
      funcDetailTag: "0",
      funcDetailImg: "",
    );
    if (userInfo?.isFormal == 0) {
      ///未登录直接拉起微信登录
      _performWechatLogin();
    } else {
      ///已绑定微信
      if (userInfo?.isBindPhone == 0) {
        ///未绑定手机号
        userController.showBindPhoneDialog(showTitle: true);
        return;
      }
      if (userInfo?.isBindWx == 1) {
        Get.normalDialog(
          width: Get.width * 0.85,
          title: '温馨提示',
          content: '您已绑定微信，是否切换其他微信号登陆？',
          confirmText: '否',
          cancelText: '是',
          confirmAction: () {
            Get.back();
          },
          cancelAction: () {
            userController.logoutRequest(onSuccess: () {
              _performWechatLogin();
            });
          },
        );
      } else {
        ///未绑定微信直接拉起微信登录
        _performWechatLogin();
      }
    }
  }

  ///执行微信登录
  void _performWechatLogin() {
    final context = Get.context;
    if (context == null) return;

    final loginProvider = context.read<LoginProvider>();

    // Android平台需要先订阅微信登录响应
    if (Platform.isAndroid) {
      loginProvider.subscribeWXLoginResp(context);
    }

    // 设置登录成功回调
    loginProvider.loginSuccess = () async {
      await userController.reloadUserInfo();
      getDataFromServer();
    };

    // 调用微信登录
    loginProvider.wxLogin();
  }
}
