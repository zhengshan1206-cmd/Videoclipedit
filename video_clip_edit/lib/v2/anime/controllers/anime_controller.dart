import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import '../../../controller/user_controller.dart';
import '../../../providers/launch_provider.dart';
import '../../../routes/route_utils.dart';
import '../../aiOralVideos/ai_oral_video_management_page.dart';
import '../../aiVideo/provider/ai_square_provider.dart';
import '../../integral/integral_vip_controller.dart';
import '../beans/anime_bean.dart';
import '../pages/anime_no_intergral_dialog.dart';

class AnimeController extends GetxController {
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;

  ///数据列表
  RxList<AnimeBean> dataList = <AnimeBean>[].obs;

  ///分辨率积分配置消耗
  Map? configIntergral;

  @override
  void onInit() {
    fetchAnimeList();
    fetchAnimeConfig();
    super.onInit();
  }

  ///获取当前分辨率下的每秒所消耗的积分
  int _getIntergralForCurrentResolution(int index) {
    final String key = index == 0
        ? '480P'
        : index == 1
            ? '720P'
            : '1080P';
    try {
      return configIntergral![key]!;
    } catch (e) {
      return 3;
    }
  }

  ///非vip并且无试用时跳转付费页弹窗
  bool canCreate() {
    final integralVipController = IntegralVipController.getOrPut();
    if (!checkVip() && integralVipController.isTest <= 0) {
      ///显示积分不够弹窗
      showDialog(
          context: Get.context!,
          builder: (context) {
            return AnimeNoIntergralDialog(
              action: () {
                final provider = Get.context!.read<AiSquareProvider>();
                String mark = 'anime';
                provider.showModelPayDialog(Get.context!, mark);
              },
            );
          });
      return false;
    }
    return true;
  }

  ///获取当前配置消耗积分
  int consumeIntergral(int index, AnimeBean bean) {
    final intergralPerSecond = _getIntergralForCurrentResolution(index);
    int duration = 1;
    try {
      final double duraDouble = double.parse(bean.duration!);
      final double ceilDuration = duraDouble.ceilToDouble();
      duration = ceilDuration.toInt();
    } catch (e) {
      duration = 1;
    }
    return intergralPerSecond * duration;
  }

  ///检查用户是否是vip
  bool checkVip() {
    final isVip = Get.context!.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }

  ///跳转至记录页
  void gotoRecord() {
    RouteUtils.gotoPage(Get.context!, '/anime_works',
        params: ManagementRecord.aiAnime);
  }

  ///获取漫剧列表
  void fetchAnimeList() {
    statusType.value = MultiStatusType.statusLoading;
    HttpUtils.get(
      APIs.animeList,
      {},
      success: (data) {
        final List items = data['data'] ?? [];
        final List<AnimeBean> beans =
            items.map((e) => AnimeBean.fromJson(json: e)).toList();
        dataList.clear();
        dataList.addAll(beans);
        if (dataList.isEmpty) {
          statusType.value = MultiStatusType.statusEmpty;
        } else {
          statusType.value = MultiStatusType.statusContent;
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
      },
    );
  }

  ///获取分辨率及对应积分消耗配置
  void fetchAnimeConfig() {
    HttpUtils.get(
      APIs.animeConfig,
      {},
      showMsgWhenFailed: false,
      success: (data) {
        try {
          configIntergral = data['data']['model']['perSecondIntegral'];
        } catch (e) {
          // print("$e");
        }
      },
    );
  }

  ///创建漫剧
  void createAnime(
    int id,

    ///模版ID
    String styleID,

    ///画风ID
    String scale,

    ///视频比例
    String resolution,

    ///分辨率
  ) {
    Map<String, dynamic> params = {
      'type': "1",
      "template_id": '${id}',
      "scale": scale,
      "resolution": resolution
    };
    if (styleID.isNotEmpty) {
      params["style"] = styleID;
    }
    HttpUtils.post(
      APIs.animeCreate,
      params,
      showLoading: true,
      success: (data) {
        BotToast.showText(text: '创建成功');
        Get.back();
        gotoRecord();
        // 更新用户信息以刷新积分
        if (Get.isRegistered<UserController>()) {
          Get.find<UserController>().reloadUserInfo();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
