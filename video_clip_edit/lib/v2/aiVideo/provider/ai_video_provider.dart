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
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

import '../../../widgets/toast_util.dart';

class AiVideoProvider extends AiSettingsMixin {
  AiVideoGenerationType type = AiVideoGenerationType.textToVideo;
  updateType(AiVideoGenerationType type) {
    this.type = type;
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
        // EasyLoading.dismiss();
        // BotToast.showText(text: msg);

        ToastUtil().showToast(msg);
      },
    );
  }

  // replaceWithInitialLetterOfPinyin() {
  //   String content = desc;
  //   for (var e in bandedWords) {
  //     content = content.replaceAll(e, e.getFirstLetters());
  //   }
  //   return content;
  // }

  // /// 将选中的违禁词替换为[word]
  // replaceWord(String word, Function call) {
  //   final contents = desc.replaceAll(selectedBandedWord, word);
  //   byDebugPrint(contents);
  //   bandedWords.removeWhere((item) => item == selectedBandedWord);
  //   updateBandedWords(List<String>.from(bandedWords));
  //   desc = contents;
  //   call();
  // }

  // deleteImage({
  //   required imgId,
  //   void Function()? onSuccess,
  // }) {
  //   HttpUtils.post(
  //     APIs.cleanItemImg,
  //     {"pid": pid, "id": imgId},
  //     success: (data) {
  //       byDebugPrint(data);
  //       onSuccess?.call();
  //     },
  //     fail: (code, msg) {
  //       BotToast.showText(text: msg);
  //     },
  //   );
  // }

  /// 预制提示词
  void loadPrompts(
      {required AiVideoGenerationType type,
      required void Function(List<dynamic>) onSuccess}) {
    HttpUtils.get(
      "VideoAi/getDefaultPrompt",
      {
        "type": type.code,
      },
      success: (data) {
        if (data["data"] is List) {
          final prompts = (data["data"] as List);
          byDebugPrint(prompts);
          onSuccess(prompts);
        }
      },
      fail: (code, msg) {
        /// BotToast.showText(text: msg);
      },
    );
  }

  void generate({
    required AiVideoGenerationType generationType,
    String? prompt,
    String? negativePrompt,
    List<String>? images,
    String? imageTail,
    bool? optimizePrompt,
    double? cfgScale,
    String? aspectRatio,
    int? duration,
    String? mode,
    void Function()? onSuccess,
    String? bgmUrl,
  }) {
    optimizePrompt ??= true;
    cfgScale ??= 0.5;
    aspectRatio ??= "16:9";
    duration ??= 5;
    mode ??= "std";
    dynamic args;
    String mark = "ai_text_to_video";
    if (generationType == AiVideoGenerationType.textToVideo) {
      mark = "ai_text_to_video";
      if (prompt == null || prompt.isEmpty) {
        BotToast.showText(text: "请输入创意描述");
        return;
      }
      args = {
        "prompt": prompt,
        "negative_prompt": negativePrompt,
        "cfg_scale": double.parse(cfgScale.toStringAsFixed(2)),
        "optimize_prompt": optimizePrompt ? 1 : 2,
        "aspect_ratio": aspectRatio,
        "duration": duration,
        "mode": mode,
      };
    } else if (generationType == AiVideoGenerationType.imageToVideo) {
      mark = "ai_image_to_video";
      if (images == null || images.isEmpty) {
        BotToast.showText(text: "请上传图片");
        return;
      }
      args = {
        "images": images,
        "image_tail": imageTail,
        "prompt": prompt,
        "negative_prompt": negativePrompt,
        "optimize_prompt": optimizePrompt ? 1 : 2,
        "cfg_scale": double.parse(cfgScale.toStringAsFixed(2)),
        "aspect_ratio": aspectRatio,
        "duration": duration,
        "mode": mode,
      };
    } else if (generationType == AiVideoGenerationType.embraceVideo) {
      mark = "ai_embrace_video";
      if (images == null || images.length < 2) {
        BotToast.showText(text: "请上传图片");
        return;
      }
      args = {
        "images": images,
        "image_tail": imageTail,
        "negative_prompt": negativePrompt,
        "optimize_prompt": optimizePrompt ? 1 : 2,
        "cfg_scale": double.parse(cfgScale.toStringAsFixed(2)),
        "aspect_ratio": aspectRatio,
        "duration": duration,
        "mode": mode,
      };
    }

    args["bgm_url"] = bgmUrl;

    HttpUtils.post(
      "VideoAi/createAiVideoTask",
      args,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        final integralVipController = IntegralVipController.getOrPut();

        integralVipController.handleStatusCode(code, msg, mark);
      },
    );
  }

  void loadRights(
      {required AiVideoGenerationType type,
      required void Function(RightsByType) onSuccess}) {
    HttpUtils.post(
      APIs.getRightsByType,
      {
        "type": switch (type) {
          AiVideoGenerationType.textToVideo => "ai_text2_video",
          AiVideoGenerationType.imageToVideo => "ai_image2_video",
          AiVideoGenerationType.embraceVideo => "ai_image2_video",
          AiVideoGenerationType.firstAndEndFrame => "ai_video_f2e",
          AiVideoGenerationType.multipleImages => "ai_video_multi",
        },
      },
      success: (data) {
        byDebugPrint(data["data"]);
        final rghtsByType = RightsByType.fromJson(data["data"]);
        onSuccess(rghtsByType);
      },
      fail: (code, msg) {
        /// BotToast.showText(text: msg);
      },
    );
  }

  void loadVideos({
    AiVideoGenerationType? type,
    int page = 1,
    int pageSize = 10,
    required void Function(List<AiVideoSquareModel> data) onSuccess,
    required void Function() onFailed,
  }) {
    HttpUtils.get(
      APIs.aiVideoCategoryDetail,
      {
        "page": page,
        "pageSize": pageSize,
        if (type != null) "category_id": type.code,
      },
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          onFailed.call();
          return;
        }
        final List items = data["data"]["data"] ?? [];
        final caseBeans = List<AiVideoSquareModel>.from(items.map(
          (ele) => AiVideoSquareModel.fromJson(ele),
        ));
        onSuccess.call(caseBeans);
      },
      fail: (code, msg) {
        onFailed.call();
        BotToast.showText(text: msg);
      },
    );
  }
}
