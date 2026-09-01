/*
 * @Author: cold-x
 * @Date: 2025-04-14 17:58:13
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-03 16:11:35
 * @FilePath: /video_clip_edit/lib/v2/profile/controllers/user_profile_controller.dart
 * @Description: 
 */
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';

import '../../../utils/comon/by_navigator_util.dart';

class UserProfileController extends GetxController {
  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    _worker = ever(userController.user, (user) {
      update();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  ///复制id
  void copyShortId() {
    final content = userInfo?.userId ?? '';
    Clipboard.setData(ClipboardData(text: '$content'));
    EasyLoading.showSuccess('复制成功');
  }

  void phoneAction() {
    if ((userInfo?.isFormal ?? 0) == 0 && (userInfo?.isVip ?? 0) == 0) {
      ///未登录
      login();
    } else if ((userInfo?.isBindPhone ?? 0) == 0) {
      ///已登录 未绑定手机号
      userController.showBindPhoneDialog(showTitle: true);
    }
  }

  void login() {
    ByNavigatorUtil.checkLogin(context: Get.context!, nextStepEvent: (){});
  }

  ///退出登陆
  void logout() {
    userController.logout();
  }

  ///注销账号
  void deleteAccount() {
    userController.deleteAccount();
  }

  @override
  void onClose() {
    super.onClose();
    _worker?.dispose();
  }
}
