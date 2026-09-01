import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/core/network/api.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_captions_config_bean.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_request.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_video_ratio_bean.dart';
import 'package:video_clip_edit/data/model/common/common_notice_bean.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_cat_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';

import '../../../widgets/toast_util.dart';
import '../../hotCreate/providers/novel_create_provider.dart';

abstract class BaseAiCreateController extends BaseController {
  AiCreateRequest get aiCreateRequest;

  ///音色列表
  var voiceList = <AiCartoonDubbingBean>[];

  ///视频比例列表
  var videoRatioList = <AiCreateVideoRatioBean>[];

  ///字幕配置
  var captionsConfigBean = AiCreateCaptionsConfigBean();

  final double fontsizeMinValue = 28;
  final double fontsizeMaxValue = 52;

  //字体默认大小
  final double fontsizeNormalValue = 40;

  ///公告
  var noticeList = RxList<CommonNoticeBean>();

  ///违禁词列表
  var riskWordsList = <String>[];

  ///获取音色配音列表
  void getVoiceList({
    String? module,
  })  async {
    HttpUtils.post(
      FolkStoryApi.FolkStoryModelSpeaker,
      {"page": 1, "limit": 999, 'module': module},
      success: (data) {
        final List speakerList = data["data"]["items"] ?? [];
        List<AiCartoonDubbingBean> beans =
            speakerList.map((e) => AiCartoonDubbingBean.fromJson(e)).toList();
        aiCreateRequest.selectVoiceBean.value = beans.first;
        voiceList.assignAll(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///获取平台推荐类型列表
  void getPlatformRecommendCategoryList() async {
    HttpUtils.get(
      APIs.bgmCategoryList,
      {},
      success: (data) {
        final List bgmCateData = data["data"]["items"] ?? [];
        final List<AiCartoonBgmCatBean> beans =
            bgmCateData.map((e) => AiCartoonBgmCatBean.fromJson(e)).toList();
        if (beans.isNotEmpty) {
          /// 默认选中第一个分类
          getBgmListWithCategory('${beans.first.id}');
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///根据平台推荐类型查询背景音乐
  void getBgmListWithCategory(String categoryId) async {
    HttpUtils.get(
      APIs.bgmListNew,
      {
        "page": pageHelper.page,
        "pageSize": 200,
        // "cate": categoryId,
        // "useScenes": 4,
        "type": categoryId,
      },
      success: (data) {
        List listData = data["data"]["items"] ?? [];
        List<AiCartoonBgmBean> dataList =
            listData.map((e) => AiCartoonBgmBean.fromJson(e)).toList();

        if (dataList.isNotEmpty) {
          aiCreateRequest.selectBgmBean.value = dataList.first;
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///获取视频比例列表
  void getVideoRatioList() async {
    HttpUtils.get(
      API.videoRatio.path,
      null,
      success: (data) {
        final List items = data["data"] ?? [];
        final List<AiCreateVideoRatioBean> beans = List.from(items.map(
          (ele) => AiCreateVideoRatioBean.fromJson(ele),
        ));
        aiCreateRequest.selectRatioBean.value = beans.first;
        videoRatioList.assignAll(beans);

        getCaptionsConfig();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///获取字幕配置 todo 需要获取视频比例后调用 后期优化
  void getCaptionsConfig() async {
    HttpUtils.get(
      API.captionsConfig.path,
      null,
      success: (data) {
        captionsConfigBean = AiCreateCaptionsConfigBean.fromJson(data['data']);
        aiCreateRequest.selectCaptionsBean?.value = CaptionsSettingBean(
          position: captionsConfigBean.position?[0],
          style: captionsConfigBean.style?[0],
          fontType: captionsConfigBean.fontType?[0],
          ratioBean: aiCreateRequest.selectRatioBean.value,
          fontSize: fontsizeNormalValue,
        );
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///公告列表
  void getNoticeList() async {
    HttpUtils.get(
      API.commonNotice.path,
      {
        'position': 1,
      },
      success: (data) {
        Get.log("获取的公告列表===> $data");
        dynamic dataFromServer = data["data"];
        if(dataFromServer!=null){
          if(dataFromServer is List){
            List<CommonNoticeBean> beans = dataFromServer.map((e) => CommonNoticeBean.fromJson(e)).toList();
            noticeList.assignAll(beans);
          }
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///违禁词检测
  void checkWords({
    String? type,
    String? needMark,
    required String content,
    void Function()? onSuccess,
  }) async {
    HttpUtils.post(
      APIs.textRisk,
      {
        "type": type ?? "3",
        "needMark": needMark ?? "2",
        "labelType": "499001",
        "content": content,
      },
      showLoading: true,
      loadingText: "违禁词检测中",
      forceData: true,
      success: (data) {
        final status = data["status"] ?? 0;
        if (status == 1002) {
          ByNavRouterUtils.push(
            Get.context!,
            ChangeNotifierProvider(
              create: (BuildContext context) => AiVipGuidProvider(),
              child: const AiVipGuidPage(),
            ),
          );
          return;
        }
        if (status == -1 || status == 200) {
          final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
          final riskWords = riskBean.labelName;
          riskWordsList.assignAll(riskWords);
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }
}
