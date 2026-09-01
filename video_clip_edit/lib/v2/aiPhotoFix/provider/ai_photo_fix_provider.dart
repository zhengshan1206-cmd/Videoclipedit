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
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

class AiPhotoFixProvider extends AiSettingsMixin {
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
          // updateForbiddenState(status == 200);
          onSuccess?.call();
          // updateSubtitle(contentDetected);
        }
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

  // type=1  高清修复
  // type=2  老照片修复
  void generate({
    required String refImageUrl,
    required int type,
    void Function()? onSuccess,
  }) {
    final args = {
      "ref_image_url": refImageUrl,
      "type": type,
    };
    HttpUtils.post(
      "image/createRefixImageTask",
      args,
      success: (data) {
        byDebugPrint(data);
        onSuccess?.call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        final integralVipController = IntegralVipController.getOrPut();
        integralVipController.handleStatusCode(
            code, msg, type == 1 ? 'hd_photo_fix' : 'old_photo_fix');
      },
    );
  }

  // type=refix_image_hd  高清修复
  // type=refix_image_old  老照片修复
  void loadRights(
      {required String type, required void Function(RightsByType) onSuccess}) {
    HttpUtils.post(
      APIs.getRightsByType,
      {
        "type": type,
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
}
