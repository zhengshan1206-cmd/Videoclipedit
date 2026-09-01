import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/consts/const_keys.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class ByInitUtils {
  static init() async {
    _initLoading();

    /// 初始化PF
    await _initPF();

    final version = await ByPackageUtils.version();
    await ByStorageUtils.saveString(ConstKeys.kAppVersion, version);

    // 延迟微信SDK初始化，等待用户同意隐私政策后再初始化
    // if (Platform.isAndroid) {
    //   await WechatKitPlatform.instance.registerApp(
    //     appId: WxLoginConfig.kWechatAppID,
    //     universalLink: WxLoginConfig.kWechatUniversalLink,
    //   );
    // }

    initEasyRefresh();

    initAudioPlayer();
    // HttpUtils.initDio();
    // 延迟初始化Dio（包含HTTPDNS初始化），等待用户同意隐私政策后再初始化
    // 只初始化基础的Dio配置，不初始化HTTPDNS（HTTPDNS会进行网络请求）
    HttpUtils.initDioBasic();
  }

  static void _initLoading() {
    EasyLoading.instance
      ..maskColor = ByColorUtil.BlackColor.withOpacity(0.5)
      ..dismissOnTap = false
      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
      ..maskType = EasyLoadingMaskType.custom
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = ByColorUtil.TabTextColorSelected
      ..customAnimation = CustomAnimation();
  }

  static _initPF() async {
    SpUtil.getInstance();
  }

  static void initEasyRefresh() {
    EasyRefresh.defaultHeaderBuilder = () => ClassicHeader(
          textStyle: TextStyle(
            fontSize: 12,
            color: ByColorUtil.CommonTextColor.withOpacity(0.5),
          ),
          messageStyle: TextStyle(
            fontSize: 10,
            color: ByColorUtil.CommonTextColor.withOpacity(0.5),
          ),
          succeededIcon: Icon(
            Icons.done,
            color: ByColorUtil.TabTextColorSelected.withOpacity(0.5),
          ),
          triggerOffset: 40,
          dragText: "下拉刷新",
          armedText: '释放开始刷新',
          readyText: '刷新中...',
          processingText: '刷新中...',
          processedText: '刷新成功',
          noMoreText: '没有更多数据了',
          failedText: '刷新失败',
          messageText: '最后更新 %T',
        );
    EasyRefresh.defaultFooterBuilder = () => ClassicFooter(
          // backgroundColor: Colors.red,
          dragText: '上拉加载更多',
          armedText: '释放开始加载',
          readyText: '加载中...',
          processingText: '加载中...',
          processedText: '加载成功',
          noMoreText: '没有更多数据了',
          failedText: '加载失败',
          messageText: '最后更新 %T',
          textStyle: TextStyle(
            fontSize: 12,
            color: ByColorUtil.CommonTextColor.withOpacity(0.5),
          ),
          messageStyle: TextStyle(
            fontSize: 10,
            color: ByColorUtil.CommonTextColor.withOpacity(0.5),
          ),
          succeededIcon: Icon(
            Icons.done,
            color: ByColorUtil.TabTextColorSelected.withOpacity(0.5),
          ),
        );
  }

  static void initAudioPlayer() {
    ByAudioPlayer.sharedInstance;
  }
}

class CustomAnimation extends EasyLoadingAnimation {
  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return Image.asset(
      "assets/common/loading_large.gif",
      width: 120.w,
      height: 124.h,
    );
  }
}
