import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_config_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_style_case_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_my_work_detail_bean.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

class AiDrawProvider extends AiSettingsMixin {
  AiDrawProvider() {
    _loadDrawConfig();

    loadStyleCases(size: 20);

    loadBanners(postion: 3);
  }

  @override
  updateDesc(String txt) {
    if (txt.length > 500) {
      txt = txt.substring(0, 500);
    }
    desc = txt;
    notifyListeners();
  }

  AiDrawConfigBean? drawConfigBean;

  List<String> ratios = [];

  updateRatios(List<String> rats) {
    ratios = rats;
    notifyListeners();
  }

  String? ratio;

  int selectedRatioIndex = 0;
  updateSelectedRatioIndex(int index) {
    selectedRatioIndex = index;
    notifyListeners();
  }

  List<String> styleCategory = ["推荐", "写实"];
  int selectedStyleCategoryIndex = 0;
  updateSelectedStyleCategoryIndex(int index) {
    selectedStyleCategoryIndex = index;
    notifyListeners();
  }

  int selectedStyleId = -1;
  updateSelectedStyleId(int id) {
    selectedStyleId = id;
    notifyListeners();
  }

  void _loadDrawConfig() {
    HttpUtils.get(
      APIs.drawConfig,
      {},
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        if (data["data"] == null) return;

        final bean = AiDrawConfigBean.fromJson(data["data"]);
        drawConfigBean = bean;
        final ratios = bean.ratios.map((e) => e.scale).toList();
        if (bean.imgStyles.isNotEmpty) {
          final sid =
              selectedStyleId == -1 ? bean.imgStyles.first.id : selectedStyleId;
          updateSelectedStyleId(sid);
        }
        updateRatios(ratios);
        // notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 创作消耗的积分数
  int priceWithPoints = 1;
  updatePriceWithPoints(int points) {
    if (priceWithPoints == points) return;
    priceWithPoints = points;
    notifyListeners();
  }

  /// 限免创作次数
  int trialForFree = 3;
  updateTrialForFree(int times) {
    if (trialForFree == times) return;
    trialForFree = times;
    notifyListeners();
  }

  /// 风格案例
  List<AiDrawStyleCaseBean> styleCases = [];
  updateStyleCases(List<AiDrawStyleCaseBean> cases) {
    styleCases = cases;
    notifyListeners();
  }

  /// 选中的风格同款案例id
  int selectedCaseId = -1;
  updateSelectedCaseId(int id) {
    selectedCaseId = id;
    notifyListeners();
  }

  loadStyleCases({
    int page = 1,
    int size = 10,
  }) {
    HttpUtils.get(
      APIs.aiSquare,
      {
        "page": page,
        "size": size,
      },
      showLoading: true,
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        final caseBeans = List<AiDrawStyleCaseBean>.from(items.map(
          (ele) => AiDrawStyleCaseBean.fromJson(ele),
        ));
        updateStyleCases(caseBeans);
        if (selectedStyleId == -1) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (caseBeans.isNotEmpty) {
              updateSelectedStyleId(caseBeans.first.modelId);
            }
          });
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  bool checkParams() {
    if (desc.isEmpty) {
      BotToast.showText(text: "请输入画面描述");
      return false;
    }

    if (selectedStyleId == -1) {
      BotToast.showText(text: "请选择画面风格");
      return false;
    }
    return true;
  }

  @override
  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
  }) {
    textRisk(
      content: content,
      onSuccess: (data) {
        byDebugPrint(data, tag: "违禁词信息:");
        final status = data["status"] ?? 0;
        if (status == 1002) {
          ByNavRouterUtils.push(
            context,
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
          updateBandedWords(riskWords);
          byDebugPrint(bandedWords, tag: "违禁词列表:");
          onSuccess?.call();
        }
      },
    );
  }

  @override
  textRisk({
    String? type,
    String? needMark,
    required String content,
    void Function(dynamic)? onSuccess,
  }) {
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
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  startCreate({
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.aiImageCreate,
      showLoading: true,
      {
        "prompt": desc,
        "ratio": ratios[selectedRatioIndex],
        "model_id": selectedStyleId,
      },
      success: (data) {
        byDebugPrint(data, tag: "AI绘图:");
        final int id = data["data"]["id"] ?? -1;
        byDebugPrint(id, tag: "Ai绘图:");
        if (id == -1) {
          onFailed?.call();
        } else {
          onSuccess?.call(id);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        final integralVipController = IntegralVipController.getOrPut();
        integralVipController.handleStatusCode(code, msg, "ai_draw");
      },
    );
  }

  startSameStyleCreate({
    required AiDrawStyleCaseBean caseBean,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.aiImageCreate,
      showLoading: true,
      {
        "prompt": caseBean.prompt,
        "ratio": caseBean.ratio,
        "model_id": caseBean.modelId,
      },
      success: (data) {
        byDebugPrint(data, tag: "AI绘图:");
        final int id = data["data"]["id"] ?? -1;
        byDebugPrint(id, tag: "Ai绘图:");
        if (id == -1) {
          onFailed?.call();
        } else {
          onSuccess?.call(id);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        final integralVipController = IntegralVipController.getOrPut();
        integralVipController.handleStatusCode(code, msg, "ai_draw");
      },
    );
  }

  startSameStyleCreatePreview({
    required AiMyWorkDetailItemBean caseBean,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.aiImageCreate,
      showLoading: true,
      {
        "prompt": caseBean.prompt,
        "ratio": caseBean.ratio,
        "model_id": caseBean.modelId,
      },
      success: (data) {
        byDebugPrint(data, tag: "AI绘图:");
        final int id = data["data"]["id"] ?? -1;
        byDebugPrint(id, tag: "Ai绘图:");
        if (id == -1) {
          onFailed?.call();
        } else {
          onSuccess?.call(id);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  imageProgressQuery({
    required int id,
    void Function()? onSuccess,
    void Function()? onFailed,
    CancelToken? cancelToken,
  }) {
    HttpUtils.get(
      APIs.aiImageCreateProgress,
      cancelToken: cancelToken,
      {"id": id},
      success: (data) {
        final status = data["data"]["status"] ?? -1;
        if (status != 3) {
          imageProgressQuery(
            id: id,
            onSuccess: onSuccess,
            onFailed: onFailed,
            cancelToken: cancelToken,
          );
        } else {
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 加载我的作品
  loadAllPictures({
    int page = 1,
    int size = 10,
    void Function(List<AiDrawImgDetailsBean>)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.get(
      APIs.allAiPictures,
      {"page": page, "size": size},
      // showLoading: true,
      success: (data) {
        final workData = data["data"]["items"];

        if (workData == null) {
          onFailed?.call();
          return;
        }

        final beans = List<AiDrawImgDetailsBean>.from(
          workData.map(
            (e) => AiDrawImgDetailsBean.fromJson(e),
          ),
        );
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 加载我的作品
  loadWorkDetails({
    required int workId,
    void Function(AiMyWorkDetailItemBean?)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.get(
      APIs.picInfo,
      {"id": workId},
      showLoading: true,
      success: (data) {
        final workData = data["data"];
        byDebugPrint(workData);
        if (workData == null) {
          onFailed?.call();
          return;
        }
        final bean = AiMyWorkDetailItemBean.fromJson(workData);
        onSuccess?.call(bean);
      },
      fail: (code, msg) {
        onFailed?.call();
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  updateSectionConfigBeansFrom(AiCartoonItemBean itemBean, String value) {
    // TODO: implement updateSectionConfigBeansFrom
    throw UnimplementedError();
  }
}
