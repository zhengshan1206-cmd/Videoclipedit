import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:wechat_kit/wechat_kit.dart';
import 'package:video_clip_edit/modules/login/wx_login_config.dart';

class PermissionConfirmPage extends StatelessWidget {
  const PermissionConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  /// 用户同意隐私政策后，初始化相关服务
  static Future<void> initAfterPrivacyAgreed() async {
    // 1. 初始化User-Agent（iOS需要获取设备信息）
    await ConstKeys().initUserAgentData();

    // 2. 初始化HTTPDNS（会进行网络请求和域名预解析）
    await HttpUtils.initHttpDnsAfterPrivacyAgreed();

    // 3. 初始化FlutterBugly（腾讯崩溃分析SDK）
    FlutterBugly.init(
      androidAppId: "2b0c0df0ad",
      iOSAppId: "",
    );

    // 4. 初始化微信SDK（Android / 鸿蒙平台）
    if (ByPackageUtils.isAndroid || ByPackageUtils.isOhos) {
      await WechatKitPlatform.instance.registerApp(
        appId: WxLoginConfig.kWechatAppID,
        universalLink: WxLoginConfig.kWechatUniversalLink,
      );
    }

    // 5. 初始化友盟SDK（通过Flutter端调用，Android端已移除preInit）
    // 友盟SDK的完整初始化会在推送服务初始化时进行（UmengPushConfig.register）
    // 这里只需要确保友盟SDK不会在用户同意前初始化即可
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(),
            Positioned.fill(
              child: Image.asset(
                "assets/launch/launch_bg.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                color: ByColorUtil.BlackColor.withOpacity(0.5),
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: ByWidgetsUtil.commonContainer(
                      margin: EdgeInsets.symmetric(horizontal: 27.w),
                      padding: EdgeInsets.only(
                          left: 16.w, right: 16.w, top: 30.h, bottom: 20.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ByWidgetsUtil.commonText(
                            text: title ?? "用户协议与隐私政策提示",
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                          SizedBox(height: 20.h),
                          ByWidgetsUtil.commonRichText(
                            texts: [
                              TextSpan(
                                text: content ??
                                    "感谢您信任并使用妙笔工坊!\n我们将持续采取互联网行业通行的技术措施和数据安全保护措施，保护您的隐私和个人信息安全您可通过阅读完整的",
                              ),
                              TextSpan(
                                text: "《用户协议》",
                                style: const TextStyle(
                                  color: ByColorUtil.TabTextColorSelected,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    ByNavRouterUtils.jumpWebViewPage(
                                        context,
                                        "",
                                        "https://inchat.beiyinapp.com/api/common3/protocol");
                                  },
                              ),
                              const TextSpan(
                                text: "和",
                              ),
                              TextSpan(
                                text: "《隐私政策》",
                                style: const TextStyle(
                                  color: ByColorUtil.TabTextColorSelected,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    ByNavRouterUtils.jumpWebViewPage(
                                        context,
                                        "",
                                        ByPackageUtils.isOhos
                                            ? "https://inchat.beiyinapp.com/api/common3/privacyHarmony"
                                            : "https://inchat.beiyinapp.com/api/common3/privacy");
                                  },
                              ),
                              const TextSpan(
                                text:
                                    "了解详情。\n在上述协议中，我们将向您说明我们如何为您提供服务并保障您的用户权益，如何收集、使用、保存、共享和保护您的相关信息，以及为您提供的访问、修改、删除和您相关的信息的方式。我们会严格按照您的授权，在上述协议约定的范围内收集、存储和使用您注册信息、设备信息、日志信息、图片信息或其他经您授权的信息。使用本产品需要接入数据网络或WLAN网络。可能产生流量费用，具体详情需请您咨询当地运营商。如您已经充分阅读、理解并接受以上两份协议的内容，请您点击“同意并继续”开始接受我们的服务。",
                              ),
                            ],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            height: 44.h,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ByWidgetsUtil.commonBtn(
                                    borderColor:
                                        ByColorUtil.TabTextColorSelected,
                                    borderRadius: 12.w,
                                    title: cancelText ?? "不同意",
                                    bgColor: ByColorUtil.WhiteColor,
                                    fontWeight: FontWeight.normal,
                                    textColor: ByColorUtil.TabTextColorSelected,
                                    fontSize: 16.sp,
                                    onClick: () async {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return ExistConfirmPage(
                                            onConfirm: onConfirm,
                                          );
                                        },
                                      );
                                      // return;
                                      // if (Platform.isAndroid) {
                                      //   SystemNavigator.pop();
                                      // } else {
                                      //   await ChannelOperate.exitApp();
                                      // }
                                    },
                                  ),
                                ),
                                SizedBox(width: 20.w),
                                Expanded(
                                  child: ByWidgetsUtil.commonBtn(
                                    borderRadius: 12.w,
                                    title: confirmText ?? "同意并继续",
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    onClick: () async {
                                      final navigator = Navigator.of(context);
                                      await ByStorageUtils.saveBool(
                                          Consts.kAgreementChecked, true);
                                      navigator.pop();

                                      // 用户同意隐私政策后，立即初始化推送服务
                                      // await NotificationPermission
                                      //     .safeInitialize();

                                      onConfirm.call();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ExistConfirmPage extends StatelessWidget {
  const ExistConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(),
              Positioned.fill(
                child: Image.asset(
                  "assets/launch/launch_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 27.w),
                  color: ByColorUtil.BlackColor.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    child: ByWidgetsUtil.commonContainer(
                        margin: EdgeInsets.symmetric(horizontal: 27.w),
                        padding: EdgeInsets.only(
                            left: 16.w, right: 16.w, top: 30.h, bottom: 20.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ByWidgetsUtil.commonText(
                              text: title ?? "确认提示",
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                            SizedBox(height: 20.h),
                            ByWidgetsUtil.commonRichText(
                              texts: [
                                TextSpan(
                                  text: content ?? "进入应用前，请先同意",
                                ),
                                TextSpan(
                                  text: "《用户协议》",
                                  style: const TextStyle(
                                    color: ByColorUtil.TabTextColorSelected,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      ByNavRouterUtils.jumpWebViewPage(
                                          context,
                                          "",
                                          "https://inchat.beiyinapp.com/api/common2/protocol");
                                    },
                                ),
                                const TextSpan(
                                  text: "和",
                                ),
                                TextSpan(
                                  text: "《隐私政策》",
                                  style: const TextStyle(
                                    color: ByColorUtil.TabTextColorSelected,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      ByNavRouterUtils.jumpWebViewPage(
                                          context,
                                          "",
                                          ByPackageUtils.isOhos
                                              ? "https://inchat.beiyinapp.com/api/common3/privacyHarmony"
                                              : "https://inchat.beiyinapp.com/api/common2/privacy");
                                    },
                                ),
                                const TextSpan(
                                  text: "，否则将退出应用。",
                                ),
                              ],
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              height: 44.h,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ByWidgetsUtil.commonBtn(
                                      borderColor:
                                          ByColorUtil.TabTextColorSelected,
                                      borderRadius: 12.w,
                                      title: cancelText ?? "退出应用",
                                      bgColor: ByColorUtil.WhiteColor,
                                      fontWeight: FontWeight.normal,
                                      textColor:
                                          ByColorUtil.TabTextColorSelected,
                                      fontSize: 16.sp,
                                      onClick: () async {
                                        // 鸿蒙与 iOS 走原生退出，Android 走 SystemNavigator
                                        if (ByPackageUtils.isAndroid) {
                                          SystemNavigator.pop();
                                        } else {
                                          await ChannelOperate.exitApp();
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: ByWidgetsUtil.commonBtn(
                                      borderRadius: 12.w,
                                      title: confirmText ?? "同意并继续",
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      onClick: () async {
                                        final navigator = Navigator.of(context);
                                        await ByStorageUtils.saveBool(
                                            Consts.kAgreementChecked, true);
                                        navigator.pop();

                                        // 用户同意隐私政策后，立即初始化推送服务
                                        // await NotificationPermission
                                        //     .safeInitialize();

                                        onConfirm.call();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
