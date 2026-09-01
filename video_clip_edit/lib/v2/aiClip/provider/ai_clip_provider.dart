import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_ratio_bean.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

import '../../../widgets/toast_util.dart';

class AiClipProvider extends AiSettingsMixin {
  /// *************************************** 基本设置 ***************************************
  String commentaryDesc = "";

  /// 清理数据
  void clearData() {
    commentaryDesc = "";
    generatingCommentary = false;
    commentaryProgress = 0.0;
    // 清理其他需要重置的数据
    notifyListeners();
  }

  /// 是否正在生成解说文案
  bool generatingCommentary = false;
  updateGeneratingCommentary(bool value) {
    generatingCommentary = value;
    notifyListeners();
  }

  rewriteCommentarySimpleTextByAI({
    required String ids,
    void Function(String taskId)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.explanationDramaText,
      {"ids": ids},
      success: (data) {
        final text = data["data"]["text"] ?? "";
        onSuccess?.call(text);
      },
      showMsgWhenFailed: false,
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }

  getCommentarySimpleText({
    required String text,
    void Function(String taskId)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.getCommentarySimpleText,
      {"text": text},
      success: (data) {
        byDebugPrint(data, tag: "getCommentarySimpleText------:");
        final taskId = data["data"]["task_id"] ?? "";
        onSuccess?.call(taskId);
      },
      showMsgWhenFailed: false,
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }

  queryVoiceStyleOptimizeState({
    required String taskId,
    void Function(String result)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.queryOptimizeTextState,
      {"task_id": taskId},
      success: (data) {
        final resData = data["data"];
        final status = resData["status"] ?? "-1";

        if (status == "200") {
          final wordsStr = resData["data"];
          // 将 JSON 字符串转换为 Dart 对象 (Map)
          Map<String, dynamic> result = json.decode(wordsStr);
          final words = result["text"];
          onSuccess?.call(words ?? "");
        } else if (status == "500") {
          BotToast.showText(text: "获取解说文案失败，请稍后再试");
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            queryVoiceStyleOptimizeState(taskId: taskId, onSuccess: onSuccess);
          });
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 解说文案生成进度
  double commentaryProgress = 0.0;
  updateCommentaryProgress(double value) {
    commentaryProgress = value;
    notifyListeners();
  }

  /// 链接提取
  void parseShareUrl(
    String url, {
    void Function(dynamic data)? onSuccess,
    void Function()? onFailed,
  }) {
    HttpUtils.post(
      APIs.parseShareUrl,
      {
        "share_url": url,
        "need_video_info": 1,
      },
      showLoading: true,
      success: (data) {
        // BotToast.showText(text: data["message"]);
        onSuccess?.call(data["data"]);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
        onFailed?.call();
      },
    );
  }

  @override
  updateSectionConfigBeansFrom(AiCartoonItemBean itemBean, String value) {
    List<List<AiCartoonItemBean>> beans = sectionConfigBeans
        .map((ele) => ele.map((bean) {
              bool isCurrent = bean.type == itemBean.type;
              return bean.copyWith(value: isCurrent ? value : bean.value);
            }).toList())
        .toList();
    sectionConfigBeans = beans;
    // if (itemBean.type == AiCartoonItemBeanType.bgm) {
    //   selectedBgmUrl = value;
    // }
    notifyListeners();
  }

  /// 画面风格数据
  void loadVideoRatios() {
    HttpUtils.get(
      APIs.aiVideoScaleList,
      {
        "page": 1,
        "pageSize": 100,
      },
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        byDebugPrint(items);
        final List<AiCartoonVideoRatioBean> beans = List.from(items.map(
          (ele) => AiCartoonVideoRatioBean.fromJson(ele),
        ));
        if (selectedRatioId == -1 && beans.isNotEmpty) {
          selectedRatioId = beans.first.id;
          final scale = beans.first.scale;
          updateSectionConfigBeansFrom(sectionConfigBeans[0][1], scale);
        }
        updateVideoRatioBeans(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 获取角色配音
  loadDubbingList({
    void Function(List<DubbingBean>)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.aiSpeakerList,
      // {"platform": "volcengine", "size": 999},
      {"page": 1, "size": 999},
      success: (data) {
        final List speakerList = data["data"]["items"] ?? [];
        List<AiCartoonDubbingBean> beans =
            speakerList.map((e) => AiCartoonDubbingBean.fromJson(e)).toList();
        if (selectedDubbingId == -1 && beans.isNotEmpty) {
          selectedDubbingId = beans.first.id;
          final name = beans.first.name;
          updateSectionConfigBeansFrom(sectionConfigBeans[0][0], name);
        }
        updateDubbingBeans(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  String pid = "";

  bool checkMaterials({
    required AiMaterialProvider materialProvider,
  }) {
    switch (materialProvider.currentType) {
      case AiMaterialType.clip:
        if (materialProvider.selectedClipMaterials.isEmpty) {
          return false;
        }
        break;
      case AiMaterialType.show:
        if (materialProvider.selectedShowId == -1) {
          return false;
        }
        break;
      case AiMaterialType.mine:
        if (materialProvider.selectedMineMaterialItemBeans.isEmpty) {
          return false;
        }
        break;
      default:
    }
    return true;
  }

  bool checkParamas({
    required AiMaterialProvider materialProvider,
  }) {
    if (desc.isEmpty) {
      BotToast.showText(text: "请输入提示词");
      return false;
    }
    if (!checkMaterials(materialProvider: materialProvider)) {
      BotToast.showText(text: "请选择混剪素材");
      return false;
    }
    if (selectedDubbingId == -1) {
      BotToast.showText(text: "请选择音色配音");
      return false;
    }
    if (selectedRatioId == -1) {
      BotToast.showText(text: "请选择视频比例");
      return false;
    }
    return true;
  }

  /// 保存第一步数据
  /// [entrance_source] 来源：1：独立功能入口 2短剧创作入口 3推文创作入口
  saveParamsForVideoStep1({
    required AiMaterialProvider materialProvider,
    required AiClipOpeningProvider openingProvider,
    void Function()? onSuccess,
    void Function()? onFaild,
  }) {
    aiTtsVideo(
      onSuccess: (int taskID) {
        final type = materialProvider.currentType;
        final isClip = type == AiMaterialType.clip;
        final packId = isClip
            ? materialProvider.selectedClipMaterials.map((e) => e.id).join(",")
            : materialProvider.selectedShowListBeans.isEmpty
                ? materialProvider.selectedShowId
                : "";
        String videoUrls = isClip
            ? ""
            : materialProvider.selectedShowListBeans
                .map((e) => e.videoUrl)
                .join(",");

        if (materialProvider.selectedMineMaterialItemBeans.isNotEmpty) {
          videoUrls = isClip
              ? ""
              : materialProvider.selectedMineMaterialItemBeans
                  .map((e) => e.url)
                  .join(",");
        }

        // final videoUrls =  materialProvider.selectedShowListBeans
        //     .map((e) => e.videoUrl)
        //     .join(",");

        log("selectedShowListBeans=======  ${materialProvider.selectedShowListBeans.length}");
        log("videoUrls=======  $videoUrls");
        // return;

        final headUrls = openingProvider.selectedOpeningBean?.videoUrl ?? "";
        HttpUtils.post(
          APIs.aiClipSave,
          {
            "title": "",
            "text": desc,
            "entrance_source": entranceSource.rawValue,
            "bgm_url": selectedBgmUrl,
            "video_template": selectedRatioId,
            "font_style": selectedFontId == -1 ? 0 : selectedFontId,
            "tts_volume": voiceVolume,

            /// 表示传入id(1)还是urls(2)
            "video_source": isClip
                ? 1
                : materialProvider.selectedShowListBeans.isEmpty
                    ? 1
                    : 2,
            "tts_param": taskID,
            "bgm_speed": bgmSpeed,
            "bgm_volume": bgmVolume,
            "video_speed": videoTimes,
            "is_show_srt": selectedFontId == -1 ? 2 : 1,
            "is_show_tts": selectedDubbingId == -1 ? 2 : 1,
            "is_show_bgm": selectedBgmUrl.isEmpty ? 2 : 1,
            "dub_speed": voiceSpeed,
            "material_pack_id": packId,
            "video_urls": videoUrls,
            "video_head_urls": headUrls,
          },
          showLoading: true,
          success: (data) {
            byDebugPrint(data);
            final pidStr = data["data"]["pid"] ?? "";
            pid = pidStr.toString();
            onSuccess?.call();
          },
          fail: (code, msg) {
            // BotToast.showText(text: msg);
            ToastUtil().showToast(msg);
            final integralVipController = IntegralVipController.getOrPut();
            integralVipController.handleStatusCode(code, msg, "ai_clip");
          },
        );
      },
      onFaild: () {},
    );
  }

  aiTtsVideo({
    void Function(int taskId)? onSuccess,
    void Function()? onFaild,
  }) {
    HttpUtils.post(
      APIs.aiTtsVideo,
      {
        "text": desc,
        "speaker": dubbingBeans.firstWhere((bean) {
          return bean.id == selectedDubbingId;
        }).speaker,
        "name": "",
        "speed": voiceSpeed,
        "pitch": 0,
        "pid": "",
        "startTask": true,
        "is_video_tts": 1
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call(data["data"]);
      },
      fail: (code, msg) => BotToast.showText(text: msg),
    );
  }

  /// *************************************** 基本设置 ***************************************
  /// *************************************** XX ***************************************

  /// *************************************** XX ***************************************
  /// *************************************** 分段处理 ***************************************
  /// 检测禁词
  @override
  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
  }) {
    if (desc.isEmpty) {
      BotToast.showText(text: "请输入小说文案");
      return;
    }
    // if (selectedStyleId == -1) {
    //   BotToast.showText(text: "请选择画面风格");
    //   return;
    // }
    if (selectedDubbingId == -1) {
      BotToast.showText(text: "请选择音色配音");
      return;
    }
    if (selectedRatioId == -1) {
      BotToast.showText(text: "请选择视频比例");
      return;
    }

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
          // context.read<PurchaseProvider>().loadVIPItems(
          //   onSuccess: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return const DailogBonusLowestPrice();
          //       },
          //     );
          //   },
          // );
          return;
        }
        if (status == -1 || status == 200) {
          final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
          final riskWords = riskBean.labelName;
          updateBandedWords(riskWords);
          byDebugPrint(bandedWords, tag: "违禁词列表:");
          // updateForbiddenState(status == 200);
          onSuccess?.call();
          // updateSubtitle(contentDetected);
        }
      },
    );
  }

  /// *************************************** 分段处理 ***************************************

  ///第一次AI改写调起
  firstGetAi({
    required String ids,
    void Function(String taskId)? onSuccess,
    void Function()? onFailed,
  }) {
    rewriteCommentarySimpleTextByAI(
        ids: ids,
        onSuccess: (data) {
          if (data.isNotEmpty) {
            updateDesc(data);
          }
        });
  }
}
