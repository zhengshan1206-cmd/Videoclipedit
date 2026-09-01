// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/login/controller/login_manager.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/modules/login/login_page.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/main/permission_confirm_page.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';

import '../../utils/comon/by_common_events.dart';
import '../../utils/push/umeng_push.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  late StreamSubscription<NetworkErrorEvent> streamSubscription;

  /// 启动进度
  int progress = 0;

  @override
  void initState() {
    super.initState();
    streamSubscription = eventBus.on<NetworkErrorEvent>().listen((e) {
      Get.offNamed(Routes.launchFaild);
    });
    checkAgreement();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
      },
      child: Scaffold(
        body: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(),
              Positioned.fill(
                child: Image.asset(
                  "assets/launch/launch_bg.png",
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                bottom: 10,
                child: SizedBox(
                  width: 300,
                  height: 4,
                  child: ProgressBar(
                    progress: progress / 100,
                    border: 2,
                    progressColor: ByColorUtil.HomeHotAuthTitleBg,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: Center(
                  child: ByWidgetsUtil.commonText(
                    fontSize: 11.sp,
                    text: '$progress%',
                    fontWeight: FontWeight.w500,
                    textColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateProgress(int pro) {
    setState(() {
      progress = pro;
    });
  }

  void checkAgreement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checked = ByStorageUtils.getBool(Consts.kAgreementChecked) ?? false;
      updateProgress(5);
      if (checked) {
        // 已同意用户启动时，也需要初始化SDK
        Future.delayed(const Duration(seconds: 1), () async {
          // 确保SDK已初始化（如果还未初始化）
          await PermissionConfirmPage.initAfterPrivacyAgreed();
          updateProgress(10);
          final provider = context.read<LaunchProvider>();
          provider.launch(
            context,
            onSuccess: (LaunchInfoBean bean) {
              final controller = Get.find<UserController>();
              ByNavigatorUtil.reportDataPoint(
                pageTag: "tourist",
                operateType: "view",
                funcDetailTag: "0",
                funcDetailImg: "",
              );
              updateProgress(55);
              // 启动时更新妙笔配置
              (controller as dynamic).checkMiaoBiConfig();
              updateProgress(60);
              (controller as dynamic).reloadUserInfo(
                successAction: (userInfo) {
                  final launchPage = bean.verConfig.launchPage;
                  updateProgress(65);

                  ///未绑定手机号时初始化闪验SDK
                  if (controller.user.value?.isBindPhone == 0) {
                    LoginManager.initShanYan();
                  }
                  updateProgress(70);
                  if (launchPage == 1 || bean.isVip == 1) {
                    provider.getPayStyle();
                    updateProgress(75);
                    Get.offNamed(Routes.main);
                  } else {
                    if ((userInfo?.isFormal ?? 0) == 1 &&
                        controller.user.value?.isBindPhone == 1) {
                      provider.getPayStyle();
                      updateProgress(75);
                      provider.gotoPay(
                        context,
                        closePay: true,
                        replace: true,
                        needCheckLogin: false,
                        cancelLogin: () {
                          Get.offNamed(Routes.main);
                        },
                      );
                    } else {
                      Get.offNamed(Routes.main);
                    }
                  }
                },
                onFailed: (int code, String msg) {
                  Get.offNamed(Routes.launchFaild);
                  FlutterBugly.uploadException(
                    message: "启动用户信息获取失败2: $code: $msg",
                    detail: msg,
                  );
                  provider.uploadLaunchError(code, msg, false, {}, 60);
                },
              );
            },
            progress: (p0) {
              updateProgress(p0);
            },
            onFail: () {
              Get.offNamed(Routes.launchFaild);
            },
          );
        });
        return;
      }
      showDialog(
        context: context,
        builder: (ctx) {
          return PermissionConfirmPage(
            onConfirm: () async {
              // 用户同意隐私政策后，初始化相关服务
              await PermissionConfirmPage.initAfterPrivacyAgreed();
              updateProgress(10);
              final provider = context.read<LaunchProvider>();
              provider.launch(
                context,
                isFirstIn: true,
                onSuccess: (LaunchInfoBean bean) async {
                  final controller = Get.find<UserController>();
                  ByNavigatorUtil.reportDataPoint(
                    pageTag: "tourist",
                    operateType: "view",
                    funcDetailTag: "0",
                    funcDetailImg: "",
                  );
                  updateProgress(40);
                  // 启动时更新妙笔配置
                  (controller as dynamic).checkMiaoBiConfig();
                  updateProgress(45);
                  // 等待用户信息更新完成后再跳转，避免异步回调在 guidePage 显示后才执行
                  // controller.reloadUserInfo(
                  //   successAction: (userInfo) {
                  //     ///未绑定手机号时初始化闪验SDK
                  //     if (controller.user.value?.isBindPhone == 0) {
                  //       LoginManager.initShanYan();
                  //     }
                  //   },
                  // );
                  // 用户信息更新完成后再跳转到 guidePage
                  Get.offNamed(Routes.guidePage);
                },
                progress: (p0) {
                  updateProgress(p0);
                },
                onFail: () {
                  Get.offNamed(Routes.launchFaild);
                },
              );
            },
          );
        },
      );
    });
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    this.progressColor,
    this.trackColor,
    this.progress,
    this.progressGradiantColor,
    this.loadingText,
    this.border,
  });

  final Color? progressColor;
  final Color? trackColor;
  final double? progress;
  final Gradient? progressGradiantColor;
  final String? loadingText;
  final double? border;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(border ?? 100),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: trackColor ?? const Color(0xFFF4F7F8)),
          ),
          FractionallySizedBox(
            widthFactor: progress ?? 0.5,
            heightFactor: 1,
            child: Container(
              decoration: progressGradiantColor != null
                  ? BoxDecoration(
                      gradient: progressGradiantColor!,
                      borderRadius: BorderRadius.circular(border ?? 100),
                    )
                  : BoxDecoration(
                      color: progressColor ?? ByColorUtil.TabTextColorSelected,
                      borderRadius: BorderRadius.circular(border ?? 100),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
