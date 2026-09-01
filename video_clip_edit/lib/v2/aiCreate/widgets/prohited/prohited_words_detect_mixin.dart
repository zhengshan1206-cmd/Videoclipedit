import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';

mixin ProhitedWordsDetectMixin {
  /// 违禁词列表
  RxList<String> bandedWords = <String>[].obs;

  /// 选中的违禁词
  RxString selectedBandedWord = "".obs;

  /// 文本违禁词检测接口调用
  textRisk({
    String? type,
    String? needMark,
    required String content,
    void Function(dynamic)? onSuccess,
    void Function()? onFail,
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
        onFail?.call();
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 开始检测违禁词
  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
    void Function()? onFail,
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
          bandedWords.value = riskWords;
          byDebugPrint(bandedWords, tag: "违禁词列表:");
          onSuccess?.call();
        } else {
          onFail?.call();
        }
      },
      onFail: onFail,
    );
  }
}
