/*
 * @Author: cold-x
 * @Date: 2025-05-07 13:44:21
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-20 14:57:00
 * @FilePath: /video_clip_edit/lib/utils/push/umeng_push.dart
 * @Description: 友盟推送模块
 */

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:umeng_push_sdk/umeng_push_sdk.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import '../../providers/launch_provider.dart';
import 'push_manager.dart';
import 'privacy_manager.dart';

//友盟推送常量
class UmengConstant {
  static const String appKey = "67ea471a65c707471a351878";
  static const String channel = "Umeng";
  static const String messageSecret = '8a08b54d6c44047eae016bcf9ff21e22';
  static const String masterSecret = "rmhfkfaidvknx6iabzfus18dwclwtyh7";
  static const String iOSKey = '681ab2d255d24d3412c7d502';
}

class UmengConstantTest {
  static const String appKey = "681d70351d106027684bfbf3";
  static const String channel = "Umeng";
  static const String messageSecret = '335ecfb2b4785b4f3b987236a2e6ec63';
  static const String masterSecret = "hgkzaou3qlfzcz3ni52jzq1a82dph0lw";
  static const String iOSKey = '681ab2d255d24d3412c7d502';
}

//检查通知权限
class NotificationPermission {
  //获取通知状态
  static Future<void> getStatus() async {
    //注册友盟推送
    UmengPushConfig.register();
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        Get.log('系统通知已开启');
        ByNavigatorUtil.reportDataPoint(
          pageTag: "push_auth_push_access_btn",
          operateType: "click",
          funcDetailTag: "0",
          funcDetailImg: "",
        );
      } else {
        Get.log('系统通知被拒绝');
        // openAppSettings();

        ByNavigatorUtil.reportDataPoint(
          pageTag: "push_auth_push_reject_btn",
          operateType: "click",
          funcDetailTag: "0",
          funcDetailImg: "",
        );
      }
    } else {
      Get.log('系统通知已经打开');
      ByNavigatorUtil.reportDataPoint(
        pageTag: "push_auth_push_access_btn",
        operateType: "click",
        funcDetailTag: "0",
        funcDetailImg: "",
      );
    }
  }

  // 新增：安全初始化推送服务（带隐私检查）
  static Future<void> safeInitialize() async {
    ByNavigatorUtil.reportDataPoint(
      pageTag: "push_auth_pop",
      operateType: "view",
      funcDetailTag: "0",
      funcDetailImg: "",
    );
    // 检查是否可以安全初始化
    if (!PrivacyManager.canInitializePushService()) {
      if (!PrivacyManager.hasAgreedPrivacy()) {
        Get.log('用户未同意隐私政策，跳过推送服务初始化');
        return;
      }
      if (PrivacyManager.isPushServiceInitialized()) {
        Get.log('推送服务已初始化，跳过重复初始化');
        return;
      }
    }

    try {
      Get.log('开始安全初始化推送服务...');

      //注册友盟推送
      UmengPushConfig.register();

      // 请求通知权限
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (result.isGranted) {
          Get.log('系统通知已开启');
          ByNavigatorUtil.reportDataPoint(
            pageTag: "push_auth_push_access_btn",
            operateType: "click",
            funcDetailTag: "0",
            funcDetailImg: "",
          );
        } else {
          Get.log('系统通知被拒绝');
          ByNavigatorUtil.reportDataPoint(
            pageTag: "push_auth_push_reject_btn",
            operateType: "click",
            funcDetailTag: "0",
            funcDetailImg: "",
          );
        }
      } else {
        Get.log('系统通知已经打开');
        ByNavigatorUtil.reportDataPoint(
          pageTag: "push_auth_push_access_btn",
          operateType: "click",
          funcDetailTag: "0",
          funcDetailImg: "",
        );
      }

      // 标记推送服务已初始化
      await PrivacyManager.markPushServiceInitialized();

      Get.log('推送服务安全初始化完成');
    } catch (e) {
      Get.log('推送服务初始化失败: $e');
    }
  }
}

class UmengPushConfig {
  //注册友盟
  static void register({bool? isTest = false}) {
    UmengPushSdk.setLogEnable(true);
    //正式环境
    if (isTest == false) {
      UmengCommonSdk.initCommon(UmengConstant.appKey, UmengConstant.iOSKey,
          UmengConstant.channel, UmengConstant.messageSecret);
      UmengPushSdk.register(UmengConstant.iOSKey, "AppStore");
    }
    //测试环境
    else {
      UmengCommonSdk.initCommon(
          UmengConstantTest.appKey,
          UmengConstantTest.iOSKey,
          UmengConstantTest.channel,
          UmengConstantTest.messageSecret);
      UmengPushSdk.register(UmengConstantTest.iOSKey, "AppStore");
    }

    //获取回调
    msgCallBack();
  }

  static void msgCallBack() {
    UmengPushSdk.setPushEnable(true);

    Future.delayed(const Duration(seconds: 5), () {
      //打印并上传友盟推送的token
      UmengPushSdk.getRegisteredId().then((deviceToken) {
        if (deviceToken != null) {
          Get.log('~~~~~友盟token：：：PPPP====>$deviceToken');
          DeviceInfoUpload.uploadUserDeviceInfo(pushToken: deviceToken);
        }
      });
    });
    //设置通知消息回调
    UmengPushSdk.setNotificationCallback((receive) {
      Get.log("~~~~~ 通知到达：receive:" + receive);
    }, (open) {
      Get.log("~~~~~ 通知点击：open:" + open);
      PushManager.handlePushNotification(open);
    });

    UmengPushSdk.setMessageCallback((message) {
      Get.log("~~~~~ 透传消息：" + message);
    });
  }
}
