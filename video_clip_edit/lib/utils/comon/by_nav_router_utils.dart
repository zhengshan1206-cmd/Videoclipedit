// description:  路由跳转工具类（原生封装）
import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/modules/login/wx_login_config.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/widgets/base_web_view.dart';

class ByNavRouterUtils {
  static void fadeIn(BuildContext context, Widget scene, {String? name}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) =>
            scene,
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        settings: name != null ? RouteSettings(name: name) : null,
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          var begin = 0.8;
          var end = 1.0;
          var curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// 跳转
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致滑动返回卡顿和点击失效的问题
  /// 使用 PageRouteBuilder 自定义淡入淡出动画，不缩放，像旧版本一样自然
  static Future push(BuildContext context, Widget scene, {String? name}) {
    FocusScope.of(context).requestFocus(FocusNode());

    // 如果没有传递 name，尝试从 GetX 获取当前路由作为备用
    String? routeName = name;
    if (routeName == null || routeName.isEmpty) {
      try {
        final getXRoute = Get.currentRoute;
        if (getXRoute.isNotEmpty && getXRoute != '/') {
          routeName = getXRoute;
        }
      } catch (e) {
        // GetX 未初始化或获取失败，忽略
      }
    }

    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        settings: routeName != null ? RouteSettings(name: routeName) : null,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放，修复 Flutter 新版本的缩放问题
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// 跳转Name
  static pushNamed(BuildContext context, String name, {Object? arguments}) {
    return Navigator.pushNamed(context, name, arguments: arguments);
  }

  /// 跳转Name
  static pushReplacementNamed(BuildContext context, String name,
      {Object? arguments}) {
    return Navigator.pushReplacementNamed(context, name, arguments: arguments);
  }

  /// 替换页面 当新的页面进入后，之前的页面将执行dispose方法
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static pushReplacement(BuildContext context, Widget scene, {String? name}) {
    return Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        settings: name != null ? RouteSettings(name: name) : null,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// 指定页面加入到路由中，然后将其他所有的页面全部pop
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static pushAndRemoveUntil(BuildContext context, Widget scene) {
    return Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => scene,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 使用淡入淡出动画，不缩放
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
        (route) => false);
  }

  ///  跳转 - 带回调参数
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static pushNamedResult(
      BuildContext context, Widget scene, Function(dynamic) function) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => scene,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ).then((result) {
      // 页面返回result为null
      if (result == null) {
        return;
      }
      function(result);
    }).catchError((error) {});
  }

  /// 返回
  static void goBack(BuildContext context) {
    unFocus();
    EasyLoading.dismiss();
    Navigator.pop(context);
  }

  /// 返回
  static void goBackUntilName(BuildContext context, String name) {
    unFocus();
    Navigator.popUntil(context, (route) {
      return route.settings.name == name;
    });
  }

  /// 带参数返回
  static void goBackWithParams(BuildContext context, result) {
    unFocus();
    Navigator.pop(context, result);
  }

  /// 拉起微信客服：鸿蒙走 OpenCustomerServiceChat（需配置 corpId），Android/iOS 为检测微信后打开客服链接 WebView
  /// [kfUrl] 客服链接（如 https://work.weixin.qq.com/kfid/kfcxxxxx）
  /// [corpId] 可选，企业 ID（鸿蒙必填才走 SDK 拉起；未填时鸿蒙 fallback 同现有逻辑）
  static Future<void> launchWechatCustomerService(
    BuildContext context,
    String title,
    String kfUrl, {
    String? corpId,
  }) async {
    if (kfUrl.isEmpty) return;
    if (ByPackageUtils.isOhos) {
      final String effectiveCorpId =
          corpId?.trim() ?? WxLoginConfig.kWechatKfCorpId;
      if (effectiveCorpId.isNotEmpty) {
        try {
          await ChannelOperate.openWechatCustomerService(
            corpId: effectiveCorpId,
            url: kfUrl,
            appId: WxLoginConfig.kWechatAppID,
          );
          return;
        } catch (_) {
          // SDK 失败（如未装微信）时 fallback 到 WebView/弹层
        }
      }
      // 无 corpId 或调用失败：沿用现有逻辑（企业微信链接走 bindSheetService，否则 WebView）
      jumpWebViewPage(context, title, kfUrl);
      return;
    }
    const String wechatUrl = 'weixin://';
    if (await canLaunchUrl(Uri.parse(wechatUrl))) {
      jumpWebViewPage(context, title, kfUrl);
    } else {
      EasyLoading.showToast('由于您未安装微信，无法直接跳转客服。');
    }
  }

  /// 跳到WebView页
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static jumpWebViewPage(
    BuildContext context,
    String title,
    String url, {
    bool isRisk = true,
  }) {
    if (ByPackageUtils.isOhos &&
        (url == "https://t020.r.sn.cn/SjFwD3" ||
            url.contains("https://work.weixin.qq.com/"))) {
      ChannelOperate.bindSheetService();
      return;
    }
    if (url.isEmpty) return;

    // 创建自定义路由，使用淡入淡出动画
    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          BaseWebView(title: title, url: url),
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用淡入淡出动画，不缩放
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );

    if (isRisk) {
      HttpUtils.post(
        APIs.dnsCheck,
        {"url": url},
        success: (json) {
          Navigator.push(context, route);
        },
        fail: (code, msg) {
          BotToast.showText(text: msg);
        },
      );
    } else {
      Navigator.push(context, route);
    }
  }

  /// 跳到WebView页 - 带返回值
  /// 修复 Flutter 新版本 MaterialPageRoute 默认缩放动画导致的问题
  static jumpWebViewPageResult(BuildContext context, String title, String url) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BaseWebView(title: title, url: url),
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用淡入淡出动画，不缩放
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
//    Navigator.of(context)
//        .push(new MaterialPageRoute(builder: (_) {
//      return WebViewPage(title:'作者博客', url: 'https://blog.csdn.net/iotjin');
//
//    }));

  static void unFocus() {
    /// 使用下面的方式，会触发不必要的build。
    /// FocusScope.of(context).unFocus();
    /// https://blog.csdn.net/iotjin
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
